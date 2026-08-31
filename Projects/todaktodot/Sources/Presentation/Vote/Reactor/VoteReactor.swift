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
        var isLoading: Bool?
        var isError: Error?
    }
    
    enum Action {
        case fetchVotes(category: CardSubject?, isClosed: Bool?, isMine: Bool?, sortLatest: Bool?, cursor: String?, size: Int?)
        case tapOption(voteId: Int, optionId: Int, isWithdrawal: Bool)
        case isLoading(Bool)
    }
    
    enum Mutation {
        case setVote(VoteInfo)
        case setVoteList(VoteList)
        case setClosedVote
        case isLoading(Bool)
        case setError(Error)
    }
    
    enum Error {
        case empty
        case network
        case voteFailure
    }
    
    let initialState = State()
    
    private let useCase: VoteUseCase
    
    init(useCase: VoteUseCase) {
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchVotes(category: let category, isClosed: let isClosed, isMine: let isMine, sortLatest: let sortLatest, cursor: let cursor, size: let size):
            useCase.fetchVotes(category: category, isClosed: isClosed, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size)
                .flatMap { voteList in
                    Observable.from([
                        .setVoteList(voteList),
                        .isLoading(false)
                    ])
                }
                .catchAndReturn(.setError(.network))
            
        case .tapOption(voteId: let voteId, optionId: let optionId, isWithdrawal: let isWithdrawal):
            useCase.voteSelect(voteId: voteId, optionId: optionId, isWithdrawal: isWithdrawal)
                .map { .setVote($0) }
                .catch {
                    if let afError = $0.asCustomAFError, afError.isClosedVote {
                        return .just(.setClosedVote)
                    }
                    return .empty()
                }
                .catchAndReturn(.setError(.voteFailure))
            
        case .isLoading(let isLoading):
            .just(.isLoading(isLoading))
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
        case .isLoading(let isLoading):
            newState.isLoading = isLoading
        case .setError(let error):
            newState.isError = error
        }
        
        return newState
    }
}
