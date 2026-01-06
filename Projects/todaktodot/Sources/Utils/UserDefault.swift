//
//  UserDefault.swift
//  Imdangg
//
//  Created by 임대진 on 11/3/24.
//

import Foundation

enum SignInType: String {
    case apple = "apple"
    case kakao = "kakao"
    case google = "google"
}

enum UserdefaultKey {
    // 저장: UserdefaultKey.test = "~~"
    // 읽기: let test = UserdefaultKey.test
    
    @UserDefault(key: "isSiginedIn", defaultValue: false)
    static var isSiginedIn: Bool
    
    //탈퇴시 적용
    static func resetUserDefaults() {
        
        UserDefaults.standard.synchronize()
    }
}


@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
