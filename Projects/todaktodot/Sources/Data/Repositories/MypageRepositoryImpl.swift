//
//  MypageRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import RxSwift
import NetworkKit
import Alamofire

final class MypageRepositoryImpl: MypageRepository {
    private let networkManager: NetworkManager
    
    init(
        networkManager: NetworkManager
    ) {
        self.networkManager = networkManager
    }
    
    func fetchInfo() -> Observable<MypageInfo> {
        let endpoint = Endpoint<UserDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/profile/detail",
            method: .get
        )

        return networkManager.request(with: endpoint)
            .map {
                $0.setUserDefaultUserInfo()
                return $0.toMypageInfo()
            }
    }
    
    func logout() -> Observable<Bool> {
        guard let provider = UserdefaultKey.loginProvider,
              let token = UserdefaultKey.accessToken else { return .just(false) }
        
        let parameters: [String: Any] = [
            "provider": provider,
            "token": token
        ]
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/logout",
            method: .post,
            parameters: parameters
        )

        return networkManager.requestOptional(with: endpoint)
            .map { _ in true }
    }
    
    func disconnectCouple() -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/couple/disconnect",
            method: .post
        )

        return networkManager.request(with: endpoint)
            .map { _ in true }
    }
    
    func withdrawal() -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/profile/withdraw",
            method: .post
        )

        return networkManager.requestOptional(with: endpoint)
            .map { _ in true }
    }
}
