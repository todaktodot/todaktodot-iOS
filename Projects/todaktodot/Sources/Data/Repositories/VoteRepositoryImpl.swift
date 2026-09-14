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
    
    func fetchVoteList(category: [CardSubject]?, isClosed: Bool?, isMine: Bool?, sortLatest: Bool?, cursor: String?, size: Int?) -> Observable<VoteList> {
        
        var parameters: [String: Any] = ["": ""]
        
        if let sortLatest {
            parameters["sortBy"] = sortLatest ? "LATEST" : "POPULAR"
        } else {
            parameters["sortBy"] = "LATEST"
        }
        
        if let category {
            var value: [String] = []
            category.forEach {
                value.append($0.rawValue)
            }
            parameters["category"] = value
        }
        
        if let isClosed {
            parameters["status"] = isClosed ? "CLOSED" : "ACTIVE"
        }
        
        if let isMine, isMine {
            parameters["isMine"] = "Y"
        }
        
        if let cursor {
            parameters["cursor"] = cursor
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
    
    func fetchMyVoteList(sortLatest: Bool?, cursor: String?, size: Int?) -> Observable<VoteList> {
        
        var parameters: [String: Any] = ["": ""]
        
        if let sortLatest {
            parameters["sortBy"] = sortLatest ? "LATEST" : "POPULAR"
        } else {
            parameters["sortBy"] = "LATEST"
        }
        
        if let cursor {
            parameters["cursor"] = cursor
        }
        
        if let size {
            parameters["size"] = size
        }
        
        let endpoint = Endpoint<VoteList>(
            baseURL: .todaktodotAPI,
            path: "/api/votes/list/my-page",
            method: .get,
            parameters: parameters
        )

        return networkManager.request(with: endpoint)
            .map { $0 }
    }
    
    func likeVote(voteId: Int, isLike: Bool) -> Observable<Void> {
        let parameters: [String: Any] = [
            "voteId": voteId
        ]
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/votes/like",
            method: isLike ? .post : .delete,
            parameters: parameters
        )

        return networkManager.requestOptional(with: endpoint)
            .map { _ in }
    }
    
    func reportVote(voteId: Int, reason: ReportType) -> Observable<Void> {
        let parameters: [String: Any] = [
            "voteId": voteId,
            "reason": reason.apiValue
        ]
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/votes/reports",
            method: .post,
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in }
    }
        
    func createVote(request: VoteCreateRequest) -> Observable<Result<VoteCreateResult, Error>> {
        let parameters: [String: Any] = [
            "category": request.category.rawValue,
            "title": request.title,
            "options": request.options.map { ["content": $0.content, "order": $0.order] }
        ]
        
        let endpoint = Endpoint<VoteCreateResult>(
            baseURL: .todaktodotAPI,
            path: "/api/votes",
            method: .post,
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map { Result<VoteCreateResult, Error>.success($0) }
            .catch { .just(.failure($0)) }
    }
    
    func updateVote(request: VoteUpdateRequest) -> Observable<Result<Void, Error>> {
        let parameters: [String: Any] = [
            "voteId": request.voteId,
            "category": request.category.rawValue,
            "title": request.title,
            "options": request.options.map { ["content": $0.content, "order": $0.order] }
        ]
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/votes",
            method: .put,
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in Result<Void, Error>.success(()) }
            .catch { .just(.failure($0)) }
    }
    
    func fetchVoteDetail(voteId: Int) -> Observable<Result<VoteInfo, Error>> {
        let endpoint = Endpoint<VoteInfo>(
            baseURL: .todaktodotAPI,
            path: "/api/votes",
            method: .get,
            parameters: ["voteId": voteId]
        )
        
        return networkManager.request(with: endpoint)
            .map { Result<VoteInfo, Error>.success($0) }
            .catch { .just(.failure($0)) }
    }
    
    func deleteVote(voteId: Int) -> Observable<Result<Void, Error>> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/votes/\(voteId)",
            method: .delete
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in Result<Void, Error>.success(()) }
            .catch { .just(.failure($0)) }
    }
}
