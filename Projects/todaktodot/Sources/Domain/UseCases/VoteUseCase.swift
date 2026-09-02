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
    
    func fetchVotes(category: [CardSubject]?, isClosed: Bool?, isMine: Bool?, sortLatest: Bool?, cursor: String?, size: Int?) -> Observable<VoteList> {
        repository.fetchVoteList(category: category, isClosed: isClosed, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size)
    }
    
    func likeVote(voteId: Int, isLike: Bool) -> Observable<Void> {
        repository.likeVote(voteId: voteId, isLike: isLike)
    }
    
    func reportVote(voteId: Int, reason: ReportType) -> Observable<Void> {
        repository.reportVote(voteId: voteId, reason: reason)
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
