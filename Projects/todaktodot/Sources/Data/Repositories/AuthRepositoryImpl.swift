//
//  AuthRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import NetworkKit
import Foundation

final class AuthRepositoryImpl: AuthRepository {
    
    private let networkManager: NetworkManager
    private let kakaoAuthProvider: KakaoAuthProvider
    private let googleAuthProvider: GoogleAuthProvider
    private let appleAuthProvider: AppleAuthProvider
    
    init(
        kakaoAuthProvider: KakaoAuthProvider,
        googleAuthProvider: GoogleAuthProvider,
        appleAuthProvider: AppleAuthProvider,
        networkManager: NetworkManager
    ) {
        self.networkManager = networkManager
        self.kakaoAuthProvider = kakaoAuthProvider
        self.googleAuthProvider = googleAuthProvider
        self.appleAuthProvider = appleAuthProvider
    }
    
    func login(type: LoginType) -> Observable<Bool> {
        switch type {
        case .kakao:
            return kakaoAuthProvider.login()
                .flatMap { oauthToken in
                    return self.requestLogin(
                        accessToken: oauthToken.accessToken,
                        loginType: .kakao
                    )
                }
        case .google:
            return googleAuthProvider.login()
                .compactMap {
                    $0.user.idToken?.tokenString
                }
                .flatMap {
                    return self.requestLogin(
                        accessToken: $0,
                        loginType: .google
                    )
                }
        case .apple:
            return appleAuthProvider.login()
                .flatMap { authorizationCode in
                    return self.requestLogin(
                        accessToken: authorizationCode,
                        loginType: .apple
                    )
                }
        }
    }

    private func requestLogin(accessToken: String, loginType: LoginType) -> Observable<Bool> {
        let parameters: [String: Any] = [
            "provider": loginType.rawValue.uppercased(),
            "token": accessToken
        ]

        let endpoint = Endpoint<LoginInfo>(
            baseURL: .todaktodotAPI,
            path: "/api/login",
            method: .post,
            parameters: parameters
        )
        
        return networkManager.request(with: endpoint)
            .map {
                UserdefaultKey.accessToken = $0.accessToken
                UserdefaultKey.refreshToken = $0.refreshToken
                UserdefaultKey.loginProvider = loginType.rawValue.uppercased()
                return true
            }
    }
    
    func fetchUserInfo() -> Observable<UserInfo> {
        let endpoint = Endpoint<UserDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/profile/detail",
            method: .get
        )
        
        return networkManager.request(with: endpoint)
            .map {
                $0.setUserDefaultUserInfo()
                return $0.toUserInfo()
            }
    }
    
    func loginTest() -> Observable<Bool> {
        let endpoint = Endpoint<LoginInfo>(
            baseURL: .todaktodotAPI,
            path: "/login/test2",
            method: .post
        )
        
        return networkManager.request(with: endpoint)
            .do(onNext: { result in
                UserdefaultKey.accessToken = result.accessToken
            })
            .map { _ in true }
            .catchAndReturn(false)
    }
}
