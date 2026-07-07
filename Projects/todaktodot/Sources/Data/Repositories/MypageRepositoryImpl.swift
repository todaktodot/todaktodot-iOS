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
    
    func logout() -> Observable<Void> {
        guard let provider = UserdefaultKey.loginProvider,
              let token = UserdefaultKey.accessToken else { return .just(()) }
        
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
            .map { _ in }
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
    
    func deleteDeviceToken() -> Observable<Void> {
        guard let deviceToken = UserdefaultKey.diviceToken else {
            return .just(())
        }

        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/device-token",
            method: .delete,
            parameters: ["fcmToken": deviceToken]
        )

        return networkManager.requestOptional(with: endpoint)
            .map { _ in }
    }
    
    func updateTerms(infoAgree: Bool? = nil, marketingAgree: Bool? = nil, advertiesmentAgree: Bool? = nil) -> Observable<Bool> {
        var result: Bool = true
        var parameters: [String: String] = [:]
        
        if let info = infoAgree {
            parameters["infoAlarmYN"] = (info ? "Y" : "N")
            result = info
        }
        if let marketing = marketingAgree {
            parameters["marketingAlarmYN"] = (marketing ? "Y" : "N")
            result = marketing
        }
        if let advertiesment = advertiesmentAgree {
            parameters["advertiesmentAlarmYN"] = (advertiesment ? "Y" : "N")
            result = advertiesment
        }
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/term",
            method: .post,
            parameters: parameters
        )

        return networkManager.request(with: endpoint)
            .map { _ in
                return result
            }
    }
    
    func fetchHeatmap(startDate: String, endDate: String) -> Observable<ActivityHeatmap> {
        
        let parameters: [String: Any] = [
            "startDate": startDate,
            "endDate": endDate
        ]

        let endpoint = Endpoint<ActivityHeatmapDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/grass",
            method: .get,
            parameters: parameters
        )

        return networkManager.request(with: endpoint)
            .map {
                return $0.toHeatmap()
            }
    }
}
