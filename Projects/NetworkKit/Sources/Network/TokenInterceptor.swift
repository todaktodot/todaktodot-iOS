//
//  TokenInterceptor.swift
//  NetworkKit
//
//  Created by 임대진 on 2/17/25.
//

import Foundation
internal import Alamofire

final class TokenInterceptor: RequestInterceptor, Sendable {
    // 가변 상태 관리
    private actor TokenState {
        var isRefreshing = false
        var requestsToRetry: [(RetryResult) -> Void] = []
        
        func setIsRefreshing(_ value: Bool) { isRefreshing = value }
        func addRequest(_ request: @escaping (RetryResult) -> Void) { requestsToRetry.append(request) }
        func getAndClearRequests() -> [(RetryResult) -> Void] {
            let requests = requestsToRetry
            requestsToRetry = []
            return requests
        }
        func shouldStartRefreshing() -> Bool {
            if isRefreshing { return false }
            isRefreshing = true
            return true
        }
    }
    
    private let state = TokenState()
    private let tokenProvider: TokenProvider?
    private let refreshSession = Session(eventMonitors: [APIEventMonitor()])
    
    init(tokenProvider: TokenProvider? = nil) {
        self.tokenProvider = tokenProvider
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        let excludedPaths = ["/api/login"] // 헤더에 토큰 안넣는 API Path
        
        if let urlString = urlRequest.url?.absoluteString,
           excludedPaths.contains(where: { urlString.contains($0) }) {
            completion(.success(urlRequest))
        }
        
        if let token = tokenProvider?.fetchAccessToken() {
            urlRequest.headers.add(.authorization(bearerToken: token))
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 || response.statusCode == 500 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        print("토큰 갱신 시작")
        Task {
            if await state.shouldStartRefreshing() {
                await state.addRequest(completion)
                
                refreshAccessToken { [weak self] success in
                    Task {
                        await self?.state.setIsRefreshing(false)
                        let result: RetryResult = success ? .retry : .doNotRetry
                        let pendings = await self?.state.getAndClearRequests() ?? []
                        pendings.forEach { $0(result) }
                    }
                }
            } else {
                await state.addRequest(completion)
            }
        }
    }
    
    private func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let id = tokenProvider?.fetchUserId(),
            let token = tokenProvider?.fetchRefeshToken() else {
            print("아이디 또는 토큰 정보 없음")
            NotificationCenter.default.post(name: .logoutRequired, object: nil)
            return
        }
        
        let parameters: [String: Any] = [
            "userId": id,
            "refreshToken": token
        ]
        
        let url = "\(BaseURL.todaktodotAPI.configValue)/api/reissue"
        
        refreshSession.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate().responseDecodable(of: TokenResponse.self) { response in
                switch response.result {
                case .success(let data):
                    print("토큰 갱신 성공")
                    self.tokenProvider?.updateTokens(
                        accessToken: data.accessToken,
                        refreshToken: data.refreshToken
                    )
                    completion(true)
                case .failure:
                    print("토큰 갱신 실패")
                    NotificationCenter.default.post(name: .logoutRequired, object: nil)
                    completion(false)
                }
            }
    }
}

extension Notification.Name {
    public static let logoutRequired = Notification.Name("logoutRequired")
}
