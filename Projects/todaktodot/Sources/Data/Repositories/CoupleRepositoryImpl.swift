//
//  CoupleRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import NetworkKit

final class CoupleRepositoryImpl: CoupleRepository {
    
    private let networkManager: NetworkManager
    
    init(
        networkManager: NetworkManager
    ) {
        self.networkManager = networkManager
    }
    
    func issueCode() -> Observable<CoupleCode> {
        let endpoint = Endpoint<CoupleCode>(
            baseURL: .todaktodotAPI,
            path: "/api/couple-link/issue",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)]
        )

        return networkManager.request(with: endpoint)
    }
    
    func linkCouple() -> Observable<Bool> {
        return .just(false)
    }
}
