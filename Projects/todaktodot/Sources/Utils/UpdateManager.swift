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
    
    // MARK: - 점검 체크
    func checkMaintenanceInfo() -> MaintenanceAlertInfo? {
        let jsonString = remoteConfig["Maintenance_config"].stringValue
        
        if let data = jsonString.data(using: .utf8) {
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let enabled = json?["enabled"] as? Bool ?? false
            
            if enabled {
                let startAt = json?["startAt"] as? String
                let endAt = json?["endAt"] as? String
                let title = json?["title"] as? String ?? "지금은 이용할 수 없어요"
                let message = json?["message"] as? String ?? "서비스 점검 중(00:00 - 04:00)이에요\n더 나은 서비스를 위해 조금만 기다려주세요"
                let formatter = ISO8601DateFormatter()
                
                guard let startAt,
                      let endAt,
                      let startDate = formatter.date(from: startAt),
                      let endDate = formatter.date(from: endAt) else {
                    return nil
                }
                
                if startDate <= Date() && Date() <= endDate {
                    return MaintenanceAlertInfo(enabled: enabled, title: title, message: message, startDate: startDate, endDate: endDate)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    // MARK: - 버전 체크
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
