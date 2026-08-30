//
//  VoteRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import RxSwift
import NetworkKit
import Alamofire

final class VoteRepositoryImpl: VoteRepository {
    
    private let networkManager: NetworkManager
    
    init(
        networkManager: NetworkManager
    ) {
        self.networkManager = networkManager
    }
    
    func voteSelect(voteId: Int, optionId: Int?, isWithdrawal: Bool) -> Observable<VoteInfo> {
        var parameters: [String: Any] = [
            "voteId": voteId
        ]
        
        if let optionId {
            parameters["optionId"] = optionId
        }
        
        let endpoint = Endpoint<VoteInfo>(
            baseURL: .todaktodotAPI,
            path: "/api/votes/select",
            method: isWithdrawal ? .delete : .post,
            parameters: parameters
        )

        return networkManager.request(with: endpoint)
            .map { $0 }
    }
    
    func fetchVoteList(category: CardSubject?, status: Bool?, isMine: Bool?, sortLatest: Bool, cursor: Int?, size: Int?) -> Observable<VoteList> {
        
        var parameters: [String: Any] = [
            "sortBy": sortLatest ? "LATEST" : "POPULAR"
        ]
        
        if let category {
            parameters["category"] = category.rawValue
        }
        
        if let status {
            parameters["status"] = status ? "ACTIVE" : "CLOSED"
        }
        
        if let isMine {
            parameters["isMine"] = isMine
        }
        
        if let cursor {
            parameters["cursor"] = String(cursor)
        }
        
        if let size {
            parameters["size"] = size
        }
        
        let endpoint = Endpoint<VoteList>(
            baseURL: .todaktodotAPI,
            path: "/api/votes/list",
            method: .get,
            parameters: parameters
        )

        return networkManager.request(with: endpoint)
            .map { $0 }
    }
}
