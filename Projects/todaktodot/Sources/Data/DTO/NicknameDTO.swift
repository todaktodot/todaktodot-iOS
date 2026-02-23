//
//  NicknameDTO.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import Foundation

struct NicknameDTO: Codable {
    let userId: Int
    let nickname: String
    let message: String
}

extension NicknameDTO {
    func toNickname() -> String {
        nickname
    }
}
