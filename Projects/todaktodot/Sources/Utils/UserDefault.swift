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
    
    // MARK: - 로그인, 커플 정보
    @UserDefault(key: "userId", defaultValue: nil)
    static var userId: Int?
    
    @UserDefault(key: "coupleId", defaultValue: nil)
    static var coupleId: Int?
    
    @UserDefault(key: "couple", defaultValue: false) // 커플 연결 여부
    static var couple: Bool
    
    @UserDefault(key: "joined", defaultValue: false) // 약관 동의 여부
    static var joined: Bool
    
    @UserDefault(key: "createdCoupleInfo", defaultValue: false) // 커플 정보 입력 여부
    static var createdCoupleInfo: Bool
    
    @UserDefault(key: "createdMyNickname", defaultValue: false)
    static var createdMyNickname: Bool
    
    @UserDefault(key: "isLoggedIn", defaultValue: false)
    static var isLoggedIn: Bool
    
    @UserDefault(key: "loginProvider", defaultValue: nil)
    static var loginProvider: String?
    
    @UserDefault(key: "accessToken", defaultValue: nil)
    static var accessToken: String?
    
    @UserDefault(key: "refreshToken", defaultValue: nil)
    static var refreshToken: String?
    
    @UserDefault(key: "diviceToken", defaultValue: nil)
    static var diviceToken: String?
    
    @UserDefaultCodable(key: "coupleType", defaultValue: .null)
    static var coupleType: CoupleType
    
    @UserDefaultCodable(key: "nicknameInfo", defaultValue: nil)
    static var nicknameInfo: NicknameInfo?
    
    // MARK: -
    @UserDefault(key: "connectedDate", defaultValue: Date())
    static var connectedDate: Date
    
    @UserDefault(key: "firstMetDate", defaultValue: Date())
    static var firstMetDate: Date
    
    @UserDefault(key: "isInitialLogin", defaultValue: true)
    static var isInitialLogin: Bool
    
    @UserDefaultCodable(key: "weeklyCards", defaultValue: [])
    static var weeklyCards: [QuestionCard]
    
    @UserDefault(key: "lastWeeklyCardDate", defaultValue: nil)
    static var lastWeeklyCardDate: Date?
    
    @UserDefault(key: "lastTooltipShownDate", defaultValue: nil)
    static var lastTooltipShownDate: String?
    
    static func resetUserDefaults() {
        let preservedDeviceToken = self.diviceToken

        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        self.diviceToken = preservedDeviceToken
    }
    
    static func resetAuthUserDefaults() {
        self.accessToken = nil
        self.refreshToken = nil
        self.nicknameInfo = nil
        
        self.weeklyCards = []
        self.lastWeeklyCardDate = nil
        
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
