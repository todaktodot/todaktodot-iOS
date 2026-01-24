//
//  KakaoLoginService.swift
//  todaktodot
//
//  Created by 임대진 on 1/4/26.
//

import UIKit
import RxSwift
import RxKakaoSDKUser
import KakaoSDKUser
import KakaoSDKCommon
import KakaoSDKAuth
import Alamofire
import NetworkKit

final class KakaoLoginService {
    static let shared = KakaoLoginService()
    
    private var disposeBag = DisposeBag()
    private let networkManager = NetworkManager()
    
    private func loginKakao() -> Observable<OAuthToken> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .catch { _ in
                    UserApi.shared.rx.loginWithKakaoAccount()
                }
        } else {
            return UserApi.shared.rx.loginWithKakaoAccount()
        }
    }
    
    func signIn() -> Observable<Bool> {
        return loginKakao()
            .flatMap { oauthToken in
                return self.sendKakaoInfoToServer(oauthToken: oauthToken)
            }
            .catchAndReturn(false)
    }
    
    func sendKakaoInfoToServer(oauthToken: OAuthToken) -> Observable<Bool> {
        return Observable.create { [self] observer in
            
            let parameters: [String: Any] = [
                "provider": "KAKAO",
                "token": oauthToken.accessToken,
            ]
            let endpoint = Endpoint<Empty>(
                baseURL: .todaktodotAPI,
                path: "/login",
                method: .post,
                parameters: parameters
            )
            
            networkManager.request(with: endpoint)
                .subscribe(
                    onNext: { entity in
                        observer.onNext(true)
                        observer.onCompleted()
                    },
                    onError: { error in
                        print("Request failed with error: \(error)")
                        observer.onNext(false)
                        observer.onCompleted()
                    }
                )
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    

}
