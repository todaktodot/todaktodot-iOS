//
//  CoupleRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import NetworkKit
import Alamofire

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
    
    func connectCouple(code: String) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/couple-link/connect",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: ["linkCode": code]
        )

        return networkManager.request(with: endpoint)
            .map { _ in true }
    }
    
    func setNickname(nickname: String) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/profile/nickname",
            method: .patch,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: ["nickname": nickname]
        )

        return networkManager.request(with: endpoint)
            .map { _ in true }
    }
    
    func setCoupleInfo(date: String, stage: String) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/couple/info",
            method: .patch,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: [
                "firstMetDt": date,
                "relationshipStage": stage,
            ]
        )

        return networkManager.request(with: endpoint)
            .map { _ in true }
    }
    
    func setTerms(marketingAgree: Bool) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/term",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: [
                "marketingAndAlarmYN": marketingAgree ? "Y" : "N"
            ]
        )

        return networkManager.request(with: endpoint)
            .do(onNext: { _ in
                UserdefaultKey.joined = true
            })
            .map { _ in true }
    }
}
