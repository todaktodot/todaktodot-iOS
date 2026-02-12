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
    
    @UserDefault(key: "isSiginedIn", defaultValue: false)
    static var isSiginedIn: Bool
    
    @UserDefault(key: "couple", defaultValue: false)
    static var couple: Bool
    
    @UserDefault(key: "joined", defaultValue: false)
    static var joined: Bool
    
    @UserDefault(key: "accessToken", defaultValue: "")
    static var accessToken: String
    
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
