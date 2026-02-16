//
//  UserInfo.swift
//  todaktodot
//
//  Created by 임대진 on 2/4/26.
//

import Foundation

enum CoupleType: String {
    case null = "NULL"
    case solo = "SOLO"
    case connected = "CONNECTED"
}

struct UserInfo {
    
    let nickname: String?
    let isTerm: Bool
    let isCouple: Bool
    let coupleType: CoupleType
}
