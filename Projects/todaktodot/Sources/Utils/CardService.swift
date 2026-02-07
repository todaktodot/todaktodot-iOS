//
//  CardService.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation

struct CardService {
    static let shared = CardService()
    
    func saveWeeklyCards(_ cards: [QuestionCard]) {
        UserdefaultKey.weeklyCards = cards
    }
    
    func getTodayCard() -> QuestionCard? {
        let allCards = UserdefaultKey.weeklyCards
        let today = Date()
        
        return allCards.first { card in
            Calendar.current.isDate(card.date, inSameDayAs: today)
        }
    }
}
