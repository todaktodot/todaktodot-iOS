//
//  MakeVoteReactor.swift
//  todaktodot
//
//  Created by daye on 8/18/26.
//

import Foundation
import RxSwift
import ReactorKit
import NetworkKit

enum VoteMode {
    case create
    case edit(vote: VoteInfo)
}

enum VoteTopic: String, CaseIterable {
    case economy = "💸 경제관"
    case lifestyle = "🏡 생활관"
    case relationship = "💑 연애관"
    
    /// 서버 API 카테고리로 변환
    var cardSubject: CardSubject {
        switch self {
        case .economy:      return .economy
        case .lifestyle:    return .lifestyle
        case .relationship: return .love
        }
    }
    
    /// 서버 카테고리(CardSubject)로부터 VoteTopic 생성 (수정 모드 초기값용)
    init?(cardSubject: CardSubject) {
        switch cardSubject {
        case .economy:   self = .economy
        case .lifestyle: self = .lifestyle
        case .love:      self = .relationship
        }
    }
}

final class MakeVoteReactor: Reactor {
    
    enum Action {
        case selectTopic(VoteTopic)
        case updateQuestion(String)
        case updateAnswer(index: Int, text: String)
        case addAnswer
        case removeAnswer(index: Int)
        case submit
        case clearAlerts
    }
    
    enum Mutation {
        case setTopic(VoteTopic?)
        case setQuestion(String)
        case setAnswer(index: Int, text: String)
        case insertAnswer
        case deleteAnswer(index: Int)
        case setSubmitting(Bool)
        case setCompleted(Bool)
        case setError(Error?)
        case setHasParticipant(Bool)
        case submitFailedRetryable   // 1~3회차 재시도 가능 실패
        case submitFailedFinal       // 4회차 이상 최종 실패
        case submitFailedNetwork     // 네트워크 미연결 (카운트 제외)
        case clearAlerts
    }
    
    struct State {
        var mode: VoteMode
        var selectedTopic: VoteTopic?
        var question: String = ""
        var answers: [String] = ["", ""]
        var isSubmitting: Bool = false
        var isCompleted: Bool = false
        var error: Error?
        var showParticipantAlert: Bool = false
        var failCount: Int = 0
        var showRetryableAlert: Bool = false  // 1~3회 실패 팝업
        var showFinalAlert: Bool = false      // 4회차 실패 팝업
        var showNetworkAlert: Bool = false    // 네트워크 미연결 팝업
        
        var isValid: Bool {
            selectedTopic != nil
            && !question.trimmingCharacters(in: .whitespaces).isEmpty
            && answers.filter({ !$0.trimmingCharacters(in: .whitespaces).isEmpty }).count >= 2
        }
        
        var canAddAnswer: Bool {
            answers.count < 5
        }
        
        var canRemoveAnswer: Bool {
            answers.count > 2
        }
    }
    
    let initialState: State
    private let useCase: VoteUseCase
    
    init(mode: VoteMode, useCase: VoteUseCase) {
        var state = State(mode: mode)
        
        // 수정 모드면 기존 투표 데이터로 초기값 채움
        if case .edit(let vote) = mode {
            state.selectedTopic = vote.cardSubject.flatMap { VoteTopic(cardSubject: $0) }
            state.question = vote.title
            let contents = vote.options.map { $0.content }
            state.answers = contents.isEmpty ? ["", ""] : contents
        }
        
        self.initialState = state
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectTopic(let topic):
            let newTopic = currentState.selectedTopic == topic ? nil : topic
            return .just(.setTopic(newTopic))
            
        case .updateQuestion(let text):
            let limited = String(text.prefix(100))
            return .just(.setQuestion(limited))
            
        case .updateAnswer(let index, let text):
            let limited = String(text.prefix(21))
            return .just(.setAnswer(index: index, text: limited))
            
        case .addAnswer:
            guard currentState.canAddAnswer else { return .empty() }
            return .just(.insertAnswer)
            
        case .removeAnswer(let index):
            guard currentState.canRemoveAnswer else { return .empty() }
            return .just(.deleteAnswer(index: index))
            
        case .submit:
            guard currentState.isValid, !currentState.isSubmitting else { return .empty() }
            
            let category = currentState.selectedTopic?.cardSubject ?? .love
            let title = currentState.question.trimmingCharacters(in: .whitespaces)
            let options = currentState.answers
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .enumerated()
                .map { VoteOptionRequest(content: $0.element, order: $0.offset) }
            
            let currentFailCount = currentState.failCount
            
            let submitStream: Observable<Mutation>
            
            switch currentState.mode {
            case .create:
                let request = VoteCreateRequest(category: category, title: title, options: options)
                submitStream = useCase.createVote(request: request)
                    .map { [weak self] result -> Mutation in
                        switch result {
                        case .success:
                            return .setCompleted(true)
                        case .failure(let error):
                            return self?.mapSubmitFailure(error, currentFailCount: currentFailCount) ?? .submitFailedRetryable
                        }
                    }
                
            case .edit(let vote):
                let request = VoteUpdateRequest(voteId: vote.voteId, category: category, title: title, options: options)
                submitStream = useCase.updateVote(request: request)
                    .map { [weak self] result -> Mutation in
                        switch result {
                        case .success:
                            return .setCompleted(true)
                        case .failure(let error):
                            // 참여자 있는 투표 수정 불가는 별도 처리
                            if error.asCustomAFError?.apiErrorCode == .voteHasParticipant {
                                return .setHasParticipant(true)
                            }
                            return self?.mapSubmitFailure(error, currentFailCount: currentFailCount) ?? .submitFailedRetryable
                        }
                    }
            }
            
            return .concat([
                .just(.setSubmitting(true)),
                submitStream,
                .just(.setSubmitting(false))
            ])
            
        case .clearAlerts:
            return .just(.clearAlerts)
        }
    }
    
    /// 게시/수정 실패를 정책에 맞는 Mutation으로 변환
    /// - 네트워크 미연결: 카운트 제외 (submitFailedNetwork)
    /// - 1~3회차: 재시도 가능 팝업 (submitFailedRetryable)
    /// - 4회차 이상: 최종 실패 팝업 (submitFailedFinal)
    private func mapSubmitFailure(_ error: Error, currentFailCount: Int) -> Mutation {
        // 네트워크 미연결은 카운트 제외
        if let afError = error.asCustomAFError, afError.isNotConnected {
            return .submitFailedNetwork
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .timedOut:
                return .submitFailedNetwork
            default:
                break
            }
        }
        
        // 서버 오류/타임아웃 → 카운트 증가
        let nextCount = currentFailCount + 1
        return nextCount >= 4 ? .submitFailedFinal : .submitFailedRetryable
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTopic(let topic):
            newState.selectedTopic = topic
        case .setQuestion(let text):
            newState.question = text
        case .setAnswer(let index, let text):
            guard index < newState.answers.count else { break }
            newState.answers[index] = text
        case .insertAnswer:
            newState.answers.append("")
        case .deleteAnswer(let index):
            guard index < newState.answers.count else { break }
            newState.answers.remove(at: index)
        case .setSubmitting(let value):
            newState.isSubmitting = value
        case .setCompleted(let value):
            newState.isCompleted = value
        case .setError(let error):
            newState.error = error
        case .setHasParticipant(let value):
            newState.showParticipantAlert = value
        case .submitFailedRetryable:
            newState.failCount += 1
            newState.showRetryableAlert = true
        case .submitFailedFinal:
            newState.failCount += 1
            newState.showFinalAlert = true
        case .submitFailedNetwork:
            newState.showNetworkAlert = true
        case .clearAlerts:
            newState.showRetryableAlert = false
            newState.showFinalAlert = false
            newState.showNetworkAlert = false
            newState.showParticipantAlert = false
        }
        
        return newState
    }
}
