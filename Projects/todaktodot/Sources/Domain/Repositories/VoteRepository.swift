//
//  VoteRepository.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import RxSwift

protocol VoteRepository {
    func voteSelect(voteId: Int, optionId: Int?, isWithdrawal: Bool) -> Observable<VoteInfo>
    func fetchVoteList(category: CardSubject?, status: Bool?, isMine: Bool?, sortLatest: Bool, cursor: Int?, size: Int?) -> Observable<VoteList>
    func createVote(request: VoteCreateRequest) -> Observable<Result<VoteCreateResult, Error>>
    func updateVote(request: VoteUpdateRequest) -> Observable<Result<Void, Error>>
    func fetchVoteDetail(voteId: Int) -> Observable<Result<VoteInfo, Error>>
    func deleteVote(voteId: Int) -> Observable<Result<Void, Error>>
}
