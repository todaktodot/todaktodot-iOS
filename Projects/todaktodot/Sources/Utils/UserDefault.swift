//
//  UserDefault.swift
//  Imdangg
//
//  Created by 임대진 on 11/3/24.
//

import Foundation

enum UserdefaultKey {
    // 저장: UserdefaultKey.test = "~~"
    // 읽기: let test = UserdefaultKey.test
    @UserDefault(key: "userId", defaultValue: nil)
    static var userId: Int?
    
    @UserDefault(key: "loginProvider", defaultValue: nil)
    static var loginProvider: String?
    
    @UserDefault(key: "accessToken", defaultValue: nil)
    static var accessToken: String?
    
    @UserDefault(key: "refreshToken", defaultValue: nil)
    static var refreshToken: String?
    
    @UserDefault(key: "isLoggedIn", defaultValue: false)
    static var isLoggedIn: Bool
    
    @UserDefault(key: "couple", defaultValue: false)
    static var couple: Bool
    
    @UserDefault(key: "joined", defaultValue: false) // TODO: 이거 약관동의 완료여뷰였음 바꿔야됨
    static var joined: Bool
    
    @UserDefault(key: "connectedDate", defaultValue: Date())
    static var connectedDate: Date
    
    @UserDefault(key: "firstMetDate", defaultValue: Date())
    static var firstMetDate: Date
    
    @UserDefault(key: "coupleStage", defaultValue: CoupleStage.dating)
    static var coupleStage: CoupleStage
    
    @UserDefault(key: "isInitialLogin", defaultValue: true)
    static var isInitialLogin: Bool
    
    @UserDefaultCodable(key: "weeklyCards", defaultValue: [])
    static var weeklyCards: [QuestionCard]
    
    @UserDefault(key: "lastWeeklyCardDate", defaultValue: nil)
    static var lastWeeklyCardDate: Date?
    
    static func resetUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    static func resetAuthUserDefaults() {
        self.accessToken = nil
        self.refreshToken = nil
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
            if let optional = newValue as? AnyOptional, optional.isNil {
                UserDefaults.standard.removeObject(forKey: key)
            } else {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
    }
}

@propertyWrapper
struct UserDefaultCodable<T: Codable> {
    let key: String
    let defaultValue: T

    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.data(forKey: key) else { return defaultValue }
            return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
