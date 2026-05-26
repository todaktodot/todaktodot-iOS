//
//  KakaoAuthProvider.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import RxKakaoSDKUser
import KakaoSDKUser
import KakaoSDKAuth

struct KakaoLoginResult {
    let accessToken: String
    let appName: String?
}

final class KakaoAuthProvider {
    func login() -> Observable<KakaoLoginResult> {
        let loginObservable: Observable<OAuthToken>

        if UserApi.isKakaoTalkLoginAvailable() {
            loginObservable = UserApi.shared.rx.loginWithKakaoTalk()
                .catch { _ in
                    UserApi.shared.rx.loginWithKakaoAccount()
                }
        } else {
            loginObservable = UserApi.shared.rx.loginWithKakaoAccount()
        }

        return loginObservable
            .flatMap { token in
                Observable<KakaoLoginResult>.create { observer in
                    UserApi.shared.me { user, error in
                        if let error {
                            observer.onError(error)
                            return
                        }

                        observer.onNext(
                            KakaoLoginResult(
                                accessToken: token.accessToken,
                                appName: user?.kakaoAccount?.profile?.nickname
                            )
                        )

                        observer.onCompleted()
                    }

                    return Disposables.create()
                }
            }
    }
}
