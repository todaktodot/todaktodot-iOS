//
//  MakeVoteReactor.swift
//  todaktodot
//
//  Created by daye on 8/18/26.
//

import RxSwift
import ReactorKit

enum VoteMode {
    case create
    case edit(voteId: String)
}

enum VoteTopic: String, CaseIterable {
    case economy = "💸 경제관"
    case lifestyle = "🏡 생활관"
    case relationship = "💑 연애관"
}

final class MakeVoteReactor: Reactor {
    
    enum Action {
        case selectTopic(VoteTopic)
        case updateQuestion(String)
        case updateAnswer(index: Int, text: String)
        case addAnswer
        case removeAnswer(index: Int)
        case submit
    }
    
    enum Mutation {
        case setTopic(VoteTopic?)
        case setQuestion(String)
        case setAnswer(index: Int, text: String)
        case insertAnswer
        case deleteAnswer(index: Int)
        case setSubmitting(Bool)
        case setCompleted(Bool)
    }
    
    struct State {
        var mode: VoteMode
        var selectedTopic: VoteTopic?
        var question: String = ""
        var answers: [String] = ["", ""]
        var isSubmitting: Bool = false
        var isCompleted: Bool = false
        
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
        self.initialState = State(mode: mode)
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
            guard currentState.isValid else { return .empty() }
            return .concat([
                .just(.setSubmitting(true)),
                // TODO: API 호출
                .just(.setCompleted(true)),
                .just(.setSubmitting(false))
            ])
        }
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
        }
        
        return newState
    }
}
