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
        var isClosedVoteId: Int?
        var isLoading: Bool?
        var isError: Error?
        var isLikeLoading: Bool = false
        var reportingVoteId: Int?
    }
    
    enum Action {
        case isLoading(Bool)
        case fetchVotes(category: [CardSubject]?, isClosed: Bool?, isMine: Bool?, sortLatest: Bool?, cursor: String?, size: Int?)
        case tapOption(voteId: Int, optionId: Int, isWithdrawal: Bool)
        case tapLike(voteId: Int, isLike: Bool)
        case tapReport(voteId: Int, reason: ReportType)
        case removeVoteLocally(voteId: Int)
    }
    
    enum Mutation {
        case isLoading(Bool)
        case setVote(VoteInfo)
        case setVoteList(VoteList)
        case setClosedVoteId(Int)
        case setError(Error?)
        case setIsLikeLoading(Bool)
        case setReport(Int)
        case removeVote(voteId: Int)
    }
    
    enum Error {
        case empty
        case network
        case voteFailure
        case reportFailure
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
                .catch { _ in
                    .concat([
                        .just(.setError(.network)),
                        .just(.setError(nil))
                    ])
                }
            
        case .tapOption(voteId: let voteId, optionId: let optionId, isWithdrawal: let isWithdrawal):
            useCase.voteSelect(voteId: voteId, optionId: optionId, isWithdrawal: isWithdrawal)
                .map { .setVote($0) }
                .catch {
                    if let afError = $0.asCustomAFError, afError.apiErrorCode == .closedVote {
                        return .just(.setClosedVoteId(voteId))
                    }
                    return .empty()
                }
                .catch { _ in
                    .concat([
                        .just(.setError(.voteFailure)),
                        .just(.setError(nil))
                    ])
                }
            
        case .isLoading(let isLoading):
            .just(.isLoading(isLoading))
            
        case .tapLike(let id, let isLike):
            .just(.setIsLikeLoading(true))
            .concat(
                self.useCase.likeVote(voteId: id, isLike: isLike)
                    .map { .setIsLikeLoading(false) }
                    .catchAndReturn(.setIsLikeLoading(false))
            )
            
        case .tapReport(let id, let reason):
            useCase.reportVote(voteId: id, reason: reason)
                .map { .setReport(id) }
                .catch { _ in
                    .concat([
                        .just(.setError(.reportFailure)),
                        .just(.setError(nil))
                    ])
                }
            
        case .removeVoteLocally(let voteId):
            .just(.removeVote(voteId: voteId))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setVote(let vote):
            newState.selectedVote = vote
        case .setVoteList(let list):
            newState.voteList = list
        case .setClosedVoteId(let id):
            newState.isClosedVoteId = id
        case .isLoading(let isLoading):
            newState.isLoading = isLoading
        case .setError(let error):
            newState.isError = error
        case .setIsLikeLoading(let isLikeLoading):
            newState.isLikeLoading = isLikeLoading
        case .setReport(let id):
            newState.reportingVoteId = id
        case .removeVote(let voteId):
            if let list = newState.voteList {
                let filtered = list.data?.filter { $0.voteId != voteId }
                newState.voteList = VoteList(
                    data: filtered,
                    createVoteCnt: list.createVoteCnt,
                    nextCursor: list.nextCursor,
                    hasNext: list.hasNext
                )
            }
        }
        
        return newState
    }
}
