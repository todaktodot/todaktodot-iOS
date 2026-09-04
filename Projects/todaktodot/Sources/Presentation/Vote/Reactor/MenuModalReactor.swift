//
//  MenuModalReactor.swift
//  todaktodot
//
//  Created by daye on 8/31/26.
//

import RxSwift
import ReactorKit

final class MenuModalReactor: Reactor {
    
    enum Action {
        case tapEdit
        case confirmDelete
    }
    
    enum Mutation {
        case setChecking(Bool)
        case setEditAllowed(VoteInfo)
        case setParticipantBlocked
        case setDeleted(Bool)
    }
    
    struct State {
        let vote: VoteInfo
        var isChecking: Bool = false
        // 수정 진입 허용 (최신 참여자 없음) - 최신 VoteInfo 전달
        var editAllowedVote: VoteInfo?
        // 참여자가 생겨 수정 불가
        var isParticipantBlocked: Bool = false
        // 삭제 완료
        var isDeleted: Bool = false
        
        var isMine: Bool { vote.isMine }
        var hasParticipant: Bool { vote.participantCnt >= 1 }
        var isClosed: Bool { vote.isClosed }
    }
    
    let initialState: State
    private let useCase: VoteUseCase
    
    init(vote: VoteInfo, useCase: VoteUseCase) {
        self.initialState = State(vote: vote)
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapEdit:
            guard !currentState.isChecking else { return .empty() }
            let voteId = currentState.vote.voteId
            
            return .concat([
                .just(.setChecking(true)),
                useCase.fetchVoteDetail(voteId: voteId)
                    .map { result -> Mutation in
                        switch result {
                        case .success(let latest):
                            return latest.participantCnt >= 1
                                ? .setParticipantBlocked
                                : .setEditAllowed(latest)
                        case .failure:
                            // 조회 실패 시 기존 데이터로 수정 진입
                            return .setEditAllowed(self.currentState.vote)
                        }
                    },
                .just(.setChecking(false))
            ])
            
        case .confirmDelete:
            let voteId = currentState.vote.voteId
            return useCase.deleteVote(voteId: voteId)
                .map { result -> Mutation in
                    switch result {
                    case .success:      return .setDeleted(true)
                    case .failure:      return .setDeleted(false)
                    }
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        // 매 방출마다 일회성 플래그 초기화
        newState.editAllowedVote = nil
        newState.isParticipantBlocked = false
        
        switch mutation {
        case .setChecking(let value):
            newState.isChecking = value
        case .setEditAllowed(let vote):
            newState.editAllowedVote = vote
        case .setParticipantBlocked:
            newState.isParticipantBlocked = true
        case .setDeleted(let value):
            newState.isDeleted = value
        }
        
        return newState
    }
}
