//
//  CardService.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation

struct CardService {
    static let shared = CardService()
    
    private let calendar = Calendar.current

    /// 메모리에 카드 저장
    func saveWeeklyCards(_ cards: [QuestionCard]) {
        guard let lastDate = UserdefaultKey.lastWeeklyCardDate else {
            UserdefaultKey.weeklyCards = cards
            return
        }
        
        let keep = UserdefaultKey.weeklyCards
            .filter { $0.date == lastDate }
        
        UserdefaultKey.weeklyCards = Array(keep) + cards
    }
    
    /// 메모리에 저장된 오늘 카드 get
    func getTodayCards() -> [QuestionCard] {
        let today = getCardSystemDate()
        return UserdefaultKey.weeklyCards.filter { card in
            calendar.isDate(card.date, inSameDayAs: today)
        }
    }
    
    /// 카드 배치 기준 날짜 반환 (오전 8시 기준)
    /// - 8시 이후: 오늘 날짜
    /// - 8시 이전: 어제 날짜
    func getCardSystemDate() -> Date {
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        if hour >= 8 {
            return now
        } else {
            return calendar.date(byAdding: .day, value: -1, to: now) ?? now
        }
    }
}
