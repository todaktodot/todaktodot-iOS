//
//  BaseURL.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation

internal import Alamofire

public enum BaseURL: String {
    case todaktodotAPI = "TODAKTODOT_API"
    
    var configValue: String {
        guard let infoDictionary = Bundle.main.infoDictionary,
              let baseURL = infoDictionary[self.rawValue] as? String else {
            fatalError("⚠️ Info.plist에 '\(self.rawValue)' 설정이 누락되었습니다.")
        }
        return baseURL.decodeURL()
    }
}

extension String {
    func decodeURL() -> String {
        var urlDecodedString = self.removingPercentEncoding ?? .init()
        
        if urlDecodedString == "" {
            urlDecodedString = self
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3A%2F%2F", with: "://")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%26", with: "&")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%2F", with: "/")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3A", with: ":")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3F", with: "?")
            urlDecodedString = urlDecodedString.replacingOccurrences(of: "%3D", with: "=")
        }
        
        return urlDecodedString
    }
}
