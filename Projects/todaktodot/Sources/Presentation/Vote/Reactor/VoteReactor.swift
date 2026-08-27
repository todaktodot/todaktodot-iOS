//
//  VoteReactor.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import RxSwift
import ReactorKit

final class VoteReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var voteList: VoteList?
        var selectedVote: VoteInfo?
        var isClosedVote: Bool?
        var endRefreshing: Bool?
    }
    
    enum Action {
        case fetchVotes(category: CardSubject?, status: Bool?, isMine: Bool?, sortLatest: Bool, cursor: Int?, size: Int?)
        case refreshVotes(category: CardSubject?, status: Bool?, isMine: Bool?, sortLatest: Bool, cursor: Int?, size: Int?)
        case tapOption(voteId: Int, optionId: Int, isWithdrawal: Bool)
    }
    
    enum Mutation {
        case setVote(VoteInfo)
        case setVoteList(VoteList)
        case setClosedVote
        case endRefreshing(Bool)
    }
    
    let initialState = State()
    
    private let useCase: VoteUseCase
    
    init(useCase: VoteUseCase) {
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchVotes(category: let category, status: let status, isMine: let isMine, sortLatest: let sortLatest, cursor: let cursor, size: let size):
            useCase.fetchVotes(category: category, status: status, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size)
                .map { .setVoteList($0) }
            
        case .refreshVotes(category: let category, status: let status, isMine: let isMine, sortLatest: let sortLatest, cursor: let cursor, size: let size):
            useCase.fetchVotes(category: category, status: status, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size)
                .flatMap { voteList in
                    Observable.from([
                        .setVoteList(voteList),
                        .endRefreshing(true)
                    ])
                }
            
        case .tapOption(voteId: let voteId, optionId: let optionId, isWithdrawal: let isWithdrawal):
            useCase.voteSelect(voteId: voteId, optionId: optionId, isWithdrawal: isWithdrawal)
                .map { .setVote($0) }
                .catch {
                    if let afError = $0.asCustomAFError, afError.isClosedVote {
                        return .just(.setClosedVote)
                    }
                    return .empty()
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setVote(let vote):
            newState.selectedVote = vote
        case .setVoteList(let list):
            newState.voteList = list
        case .setClosedVote:
            newState.isClosedVote = true
        case .endRefreshing(let endRefreshing):
            newState.endRefreshing = endRefreshing
        }
        
        return newState
    }
}
