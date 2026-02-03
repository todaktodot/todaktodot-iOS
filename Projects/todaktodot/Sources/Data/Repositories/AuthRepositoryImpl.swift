//
//  AuthRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import NetworkKit

final class AuthRepositoryImpl: AuthRepository {
    
    private let networkManager: NetworkManager
    private let kakaoAuthProvider: KakaoAuthProvider
    private let googleAuthProvider: GoogleAuthProvider
//    private let appleService: AppleLoginService
    init(
        kakaoAuthProvider: KakaoAuthProvider,
        googleAuthProvider: GoogleAuthProvider,
        networkManager: NetworkManager
    ) {
        self.networkManager = networkManager
        self.kakaoAuthProvider = kakaoAuthProvider
        self.googleAuthProvider = googleAuthProvider
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
                .flatMap { signInResult in
                    return self.requestLogin(
                        accessToken: signInResult.user.accessToken.tokenString,
                        loginType: .google
                    )
                }
        case .apple:
//            return appleService.login()
            return .just(false)
        }
    }

    private func requestLogin(accessToken: String, loginType: LoginType) -> Observable<Bool> {
        let parameters: [String: Any] = [
            "provider": loginType.rawValue.uppercased(),
            "token": accessToken
        ]

        let endpoint = Endpoint<LoginInfo>(
            baseURL: .todaktodotAPI,
            path: "/login",
            method: .post,
            parameters: parameters
        )

        return networkManager.request(with: endpoint)
            .do(onNext: { result in
                UserdefaultKey.accessToken = result.accessToken
                UserdefaultKey.couple = result.couple
                UserdefaultKey.joined = result.joined
            })
            .map { _ in true }
            .catchAndReturn(false)
    }
}
