//
//  CardEnum.swift
//  todaktodot
//
//  Created by daye on 2/9/26.
//

import Foundation

enum CardType: String, Codable {
    case roleplay = "ROLEPLAY"
    case balance = "BALANCE"
    case none = "NONE"
    
    var displayName: String {
        switch self {
        case .roleplay: return "상황극"
        case .balance: return "밸런스게임"
        case .none: return ""
        }
    }
    
    var emoji: String {
        switch self {
        case .roleplay: return "🎭"
        case .balance: return "⚖️"
        case .none: return ""
        }
    }
}

// TODO: 이모지
enum CardMode: String, Codable, CaseIterable {
    case whiskey = "WHISKEY"
    case dessert = "DESSERT"
    case coffee = "COFFEE"

    var displayName: String {
        switch self {
        case .whiskey: return "위스키"
        case .dessert: return "디저트"
        case .coffee:  return "커피"
        }
    }
    
    var emoji: String {
        switch self {
        case .whiskey: return "🥃"
        case .dessert: return "🍰"
        case .coffee:  return "☕️"
        }
    }
}

enum CardSubject: String, Codable, CaseIterable {
    case love = "LOVE"
    case lifestyle = "LIFESTYLE"
    case economy = "ECONOMY"
    
    var displayName: String {
        switch self {
        case .love:      return "연애관"
        case .lifestyle: return "생활관"
        case .economy:   return "경제관"
        }
    }
    
    var emoji: String {
        switch self {
        case .love:      return "💑"
        case .lifestyle: return "🏡"
        case .economy:   return "💸"
        }
    }
}

enum QuestionType: String, Codable {
    case multipleChoice = "MULTIPLE_CHOICE"
    case subjective = "SUBJECTIVE"
    
    var displayName: String {
        switch self {
        case .multipleChoice: return "객관식"
        case .subjective: return "주관식"
        }
    }
}
