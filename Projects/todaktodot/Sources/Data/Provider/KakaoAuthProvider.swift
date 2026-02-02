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

final class KakaoAuthProvider {
    func login() -> Observable<OAuthToken> {
        if UserApi.isKakaoTalkLoginAvailable() {
            return UserApi.shared.rx.loginWithKakaoTalk()
                .catch { _ in
                    UserApi.shared.rx.loginWithKakaoAccount()
                }
        } else {
            return UserApi.shared.rx.loginWithKakaoAccount()
        }
    }
}
