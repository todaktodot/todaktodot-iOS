//
//  UserInfo.swift
//  todaktodot
//
//  Created by 임대진 on 2/4/26.
//

import Foundation

enum CoupleType: String, Codable {
    case null = "NULL"
    case solo = "SOLO"
    case connected = "CONNECTED"
}

struct UserInfo: Codable {
    let userId: Int
    let coupleId: Int?
    let isTerm: Bool
    let isCouple: Bool
    let coupleType: CoupleType
    let createdMyNickname: Bool
    let createdCoupleInfo: Bool
    let nicknameInfo: NicknameInfo?
}

struct NicknameInfo: Codable {
    let userNickname: String
    let anotherUserNickname: String
}
