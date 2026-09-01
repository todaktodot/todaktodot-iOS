//
//  VoteRepository.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import RxSwift

protocol VoteRepository {
    func voteSelect(voteId: Int, optionId: Int?, isWithdrawal: Bool) -> Observable<VoteInfo>
    func fetchVoteList(category: CardSubject?, isClosed: Bool?, isMine: Bool?, sortLatest: Bool?, cursor: String?, size: Int?) -> Observable<VoteList>
    func likeVote(voteId: Int, isLike: Bool) -> Observable<Void>
    func reportVote(voteId: Int, reason: ReportType) -> Observable<Void>
}
