//
//  CardType.swift
//  todaktodot
//
//  Created by daye on 2/9/26.
//

import Foundation

enum CardType: String, Codable {
    case situation = "SITUATION"
    case balance = "BALANCE"
    
    var displayName: String {
        switch self {
        case .situation: return "상황극"
        case .balance: return "밸런스게임"
        }
    }
}

enum CardMode: String, Codable, CaseIterable {
    case whiskey = "WHISKEY"
    case dessert = "DESSERT"
    case coffee = "COFFEE"
    case unknown = "UNKNOWN"

    var displayName: String {
        switch self {
        case .whiskey: return "위스키"
        case .dessert: return "디저트"
        case .coffee:  return "커피"
        case .unknown: return "기타"
        }
    }
}

enum CardSubject: String, Codable, CaseIterable {
    case love = "LOVE"
    case lifestyle = "LIFESTYLE"
    case economy = "ECONOMY"
    
    var displayName: String {
        switch self {
        case .love:      return "사랑"
        case .lifestyle: return "라이프스타일"
        case .economy:   return "경제"
        }
    }
}
