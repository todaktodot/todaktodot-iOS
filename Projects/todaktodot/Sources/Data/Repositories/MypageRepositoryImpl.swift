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
