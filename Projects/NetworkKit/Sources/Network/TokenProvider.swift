//
//  TokenProvider.swift
//  NetworkKit
//
//  Created by 임대진 on 2/17/26.
//

import Foundation

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

public protocol TokenProvider: Sendable {
    func fetchUserId() -> Int?
    func fetchAccessToken() -> String?
    func fetchRefeshToken() -> String?
    func updateTokens(accessToken: String, refreshToken: String)
}
