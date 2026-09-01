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
    
    func fetchVotes(category: CardSubject?, isClosed: Bool?, isMine: Bool?, sortLatest: Bool?, cursor: String?, size: Int?) -> Observable<VoteList> {
        repository.fetchVoteList(category: category, isClosed: isClosed, isMine: isMine, sortLatest: sortLatest, cursor: cursor, size: size)
    }
    
    func likeVote(voteId: Int, isLike: Bool) -> Observable<Void> {
        repository.likeVote(voteId: voteId, isLike: isLike)
    }
}
