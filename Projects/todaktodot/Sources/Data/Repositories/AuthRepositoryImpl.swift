//
//  AuthRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import NetworkKit
import Alamofire

final class AuthRepositoryImpl: AuthRepository {
    
    private let networkManager: NetworkManager
    private let kakaoAuthProvider: KakaoAuthProvider
    private let googleAuthProvider: GoogleAuthProvider
    private let appleAuthProvider: AppleAuthProvider
    
    enum AuthError: Error {
        case deviceTokenIsNil
    }
    
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
                .flatMap { result in
                    return self.requestLogin(
                        accessToken: result.accessToken,
                        loginType: .kakao,
                        name: result.appName
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
                .flatMap { result in
                    return self.requestLogin(
                        accessToken: result.authorizationCode,
                        loginType: .apple,
                        name: result.appName
                    )
                }
        }
    }
    
    private func requestLogin(accessToken: String, loginType: LoginType, name: String? = nil) -> Observable<Bool> {
        var parameters: [String: Any] = [
            "provider": loginType.rawValue.uppercased(),
            "token": accessToken
        ]
        
        if let name = name {
            parameters["name"] = name
        }
        
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
    
    func updateDeviceToken(token: String?) -> Observable<Bool> {
        guard let token else {
            print("FCM 토큰 없음")
            return Observable.error(AuthError.deviceTokenIsNil)
        }
        
        let parameters: [String: Any] = [
            "fcmToken": token,
            "deviceType" : "IOS"
        ]
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/device-token",
            method: .post,
            parameters: parameters
        )
        
        return networkManager.requestOptional(with: endpoint)
            .map { _ in true }
    }
}
