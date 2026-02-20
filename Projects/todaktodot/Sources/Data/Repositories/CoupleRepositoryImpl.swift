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
        )

        return networkManager.request(with: endpoint)
    }
    
    func connectCouple(code: String) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/couple-link/connect",
            method: .post,
            parameters: ["linkCode": code]
        )

        return networkManager.request(with: endpoint)
            .map { _ in true }
    }
    
    func updateNickname(nickname: String) -> Observable<String> {
        let endpoint = Endpoint<NicknameDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/profile/nickname",
            method: .patch,
            parameters: ["nickname": nickname]
        )

        return networkManager.request(with: endpoint)
            .map { $0.toNickname() }
    }
    
    func updateCoupleInfo(date: String, stage: String) -> Observable<CoupleInfo> {
        let endpoint = Endpoint<CoupleInfoDto>(
            baseURL: .todaktodotAPI,
            path: "/api/couple/info",
            method: .patch,
            parameters: [
                "firstMetDt": date,
                "relationshipStage": stage,
            ]
        )

        return networkManager.request(with: endpoint)
            .map { $0.toCoupleInfo() }
    }
    
    func setTerms(marketingAgree: Bool) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/term",
            method: .post,
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
    
    func fetchConnectInfo() -> Observable<ConnectInfo> {
        let endpoint = Endpoint<UserDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/profile/detail",
            method: .get,
        )

        return networkManager.request(with: endpoint)
            .map {
                $0.toConnectInfo()
            }
    }
    
    func soloStart() -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/solo/start",
            method: .post
        )

        return networkManager.request(with: endpoint)
            .map { _ in true }
    }
}
