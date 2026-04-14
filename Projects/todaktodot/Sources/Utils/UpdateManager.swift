//
//  UpdateManager.swift
//  todaktodot
//
//  Created by 임대진 on 4/12/26.
//

import Foundation
import FirebaseRemoteConfig

final class UpdateManager {
    
    static let shared = UpdateManager()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        remoteConfig.configSettings = settings
    }
    
    func fetch(completion: @escaping () -> Void) {
        remoteConfig.fetchAndActivate { _, _ in
            completion()
        }
    }
    
    func checkUpdate() -> (type: AppUpdateType, url: URL?) {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let jsonString = remoteConfig["iOS_Remote_Config"].stringValue

        if let data = jsonString.data(using: .utf8) {
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            let forceVersion = json?["minimum_version"] as? String ?? "0.0.0"
            let optionalVersion = json?["recommended_version"] as? String ?? "0.0.0"
            let urlString = json?["app_store_url"] as? String ?? "https://apps.apple.com"
            
            print("forceVersion: \(forceVersion), optionalVersion: \(optionalVersion)")
            
            if isLowerVersion(currentVersion, than: forceVersion) {
                return (.force, URL(string: urlString))
            } else if isLowerVersion(currentVersion, than: optionalVersion) {
                return (.optional, URL(string: urlString))
            } else {
                return (.none, nil)
            }
        }
        
        return (.none, nil)
    }
    
    func isLowerVersion(_ current: String, than target: String) -> Bool {
        let currentArr = current.split(separator: ".").map { Int($0) ?? 0 }
        let targetArr = target.split(separator: ".").map { Int($0) ?? 0 }
        
        for i in 0..<max(currentArr.count, targetArr.count) {
            let c = i < currentArr.count ? currentArr[i] : 0
            let t = i < targetArr.count ? targetArr[i] : 0
            
            if c < t { return true }
            if c > t { return false }
        }
        
        return false
    }
}
