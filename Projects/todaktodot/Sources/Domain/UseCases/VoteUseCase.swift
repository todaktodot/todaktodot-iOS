//
//  VoteUseCase.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import Foundation
import RxSwift

final class VoteUseCase {
    private let repository: VoteRepository
    
    init(repository: VoteRepository) {
        self.repository = repository
    }
    
    func voteSelect(voteId: Int, optionId: Int?, isWithdrawal: Bool) -> Observable<VoteInfo> {
        repository.voteSelect(voteId: voteId, optionId: optionId, isWithdrawal: isWithdrawal)
    }
    
    func fetchVotes(category: CardSubject?, status: Bool?, isMine: Bool?, sortLatest: Bool, cursor: Int?, size: Int?) -> Observable<VoteList> {
        repository.fetchVoteList(category: category, status: status, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size)
    }
    
    func createVote(request: VoteCreateRequest) -> Observable<Result<VoteCreateResult, Error>> {
        repository.createVote(request: request)
    }
    
    func updateVote(request: VoteUpdateRequest) -> Observable<Result<Void, Error>> {
        repository.updateVote(request: request)
    }
    
    func fetchVoteDetail(voteId: Int) -> Observable<Result<VoteInfo, Error>> {
        repository.fetchVoteDetail(voteId: voteId)
    }
    
    func deleteVote(voteId: Int) -> Observable<Result<Void, Error>> {
        repository.deleteVote(voteId: voteId)
    }
}
