//
//  LoginInfo.swift
//  todaktodot
//
//  Created by 임대진 on 1/31/26.
//

import Foundation

struct LoginInfo: Codable {
    let accessToken: String
    let refreshToken: String
    let couple: Bool
    let joined: Bool
}
