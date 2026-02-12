//
//  CardStorageService.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation

struct CardStorageService {
    static let shared = CardStorageService()
    
    private let calendar = Calendar.current

    func saveWeeklyCards(_ cards: [QuestionCard]) {
        guard let lastDate = UserdefaultKey.lastWeeklyCardDate else {
            UserdefaultKey.weeklyCards = cards
            return
        }
        
        let keep = UserdefaultKey.weeklyCards
            .filter { $0.date == lastDate }
        
        UserdefaultKey.weeklyCards = Array(keep) + cards
    }
    
    func getTodayCards() -> [QuestionCard] {
        let today = Date()
        return UserdefaultKey.weeklyCards.filter { card in
            calendar.isDate(card.date, inSameDayAs: today)
        }
    }
}
