//
//  AppTokenProvider.swift
//  todaktodot
//
//  Created by 임대진 on 2/17/26.
//

import Foundation
import NetworkKit

struct AppTokenProvider: TokenProvider {
    func fetchUserId() -> Int? {
        return UserdefaultKey.userId ?? nil
    }
    
    func fetchRefeshToken() -> String? {
        return UserdefaultKey.refreshToken
    }
    
    func fetchAccessToken() -> String? {
        return UserdefaultKey.accessToken
    }
    
    func updateTokens(accessToken: String, refreshToken: String) {
        UserdefaultKey.accessToken = accessToken
        UserdefaultKey.refreshToken = refreshToken
        
        print("✅ Userdefault 토큰 갱신 완료")
    }
}
