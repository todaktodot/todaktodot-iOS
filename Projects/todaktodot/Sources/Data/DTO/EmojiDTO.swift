//
//  EmojiDTO.swift
//  todaktodot
//
//  Created by daye on 5/26/26.
//

import Foundation

struct SaveEmojiRequestDTO: Encodable {
    let coupleCardId: Int
    let emojiType: String
}

struct SaveEmojiResponseDTO: Decodable {
    let userId: Int?
    let coupleCardId: Int?
    let emojiType: String?
    let questionNo: Int?
    let updateDt: String?
}
