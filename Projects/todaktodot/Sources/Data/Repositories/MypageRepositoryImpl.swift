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
            method: .get,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)]
        )

        return networkManager.request(with: endpoint)
            .map {
                $0.toMypageInfo()
            }
    }
    
    func logout() -> Observable<Bool> {
        let parameters: [String: Any] = [
            "provider": UserdefaultKey.loginProvider,
            "token": UserdefaultKey.accessToken
        ]
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/logout",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: parameters
        )

        return networkManager.requestOptional(with: endpoint)
            .map { _ in true }
    }
    
    func disconnectCouple() -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/couple/disconnect",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)]
        )

        return networkManager.request(with: endpoint)
            .map { _ in true }
    }
}
