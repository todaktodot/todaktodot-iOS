//
//  EmojiType.swift
//  todaktodot
//
//  Created by daye on 5/26/26.
//

import Foundation

enum EmojiType: String, Codable {
    case good = "GOOD"
    case heart = "HEART"
    case surprise = "SURPRISE"
    case cry = "CRY"
    case angry = "ANGRY"
    case poop = "POOP"
    
    var imageName: String {
        switch self {
        case .good: return "emoji_good"
        case .heart: return "emoji_heart"
        case .surprise: return "emoji_surprise"
        case .cry: return "emoji_cry"
        case .angry: return "emoji_angry"
        case .poop: return "emoji_poop"
        }
    }
}
