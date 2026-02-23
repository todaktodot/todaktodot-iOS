//
//  HomeReactor.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import ReactorKit
import RxSwift
import Foundation

enum AnswerStatus {
    case bothUnanswered
    case partnerAnswered
    case myAnswered
    case bothAnswered
}

final class HomeReactor: Reactor {
    
    private let cardUseCase: CardUseCase
    
    init(cardUseCase: CardUseCase) {
        self.cardUseCase = cardUseCase
    }
    
    enum Action {
        case updateAnswerStatus(AnswerStatus)
        case tapPokeButton
        case tapConnectCoupleButton
        case checkFirstLaunch
        case dismissNotificationAlert
        case fetchHistoryCards(startDate: String, endDate: String)
        case fetchWeeklyCards(startDate: String, endDate: String)
        case loadTodayCards
        case assignCards
    }
    
    enum Mutation {
        case setAnswerStatus(AnswerStatus)
        case setPoked(Bool)
        case setShowNotificationAlert(Bool)
        case setCoupleConnected(Bool)
        case setHistoryCards([QuestionCard])
        case setHistoryCardsWithStatus([QuestionCard], AnswerStatus)
        case setTodayCards([QuestionCard])
        case setError(Error)
    }
    
    struct State {
        var answerStatus: AnswerStatus = .bothUnanswered
        var isPoked: Bool = false
        var shouldShowNotificationAlert: Bool = true
        var isCoupleConnected: Bool = UserdefaultKey.coupleType == .connected
        var historyCards: [QuestionCard] = []
        var todayCards: [QuestionCard] = []
    }
    
    let initialState = State()

    func determineAnswerStatus(from cards: [QuestionCard]) -> AnswerStatus {
        let selectedCard = cards.first(where: { $0.isSelected }) ?? cards.first
        
        guard let card = selectedCard else {
            return .bothUnanswered
        }
        
        let user1Answered = card.user1Answered
        let user2Answered = card.user2Answered
        
        if user1Answered && user2Answered {
            return .bothAnswered
        } else if user1Answered {
            return .myAnswered
        } else if user2Answered {
            return .partnerAnswered
        } else {
            return .bothUnanswered
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateAnswerStatus(let status):
            return .just(.setAnswerStatus(status))
        case .tapPokeButton:
            return .just(.setPoked(true))
        case .tapConnectCoupleButton:
            return .just(.setCoupleConnected(UserdefaultKey.coupleType == .connected))
        case .checkFirstLaunch:
            return .just(.setShowNotificationAlert(true))
        case .dismissNotificationAlert:
            return .just(.setShowNotificationAlert(false))
        case .fetchHistoryCards(let startDate, let endDate):
            return cardUseCase.fetchHistoryCards(startDate: startDate, endDate: endDate)
                .map { result -> Mutation in
                    switch result {
                    case .success(let cards):
                        let today = CardService.shared.getCardSystemDate()
                        let calendar = Calendar.current
                        let todayCards = cards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                        let status = todayCards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: todayCards)
                        return .setHistoryCardsWithStatus(cards, status)
                    case .failure(let error):
                        let mockCards = MockCardData.historyCards
                        let today = Date()
                        let calendar = Calendar.current
                        let todayCards = mockCards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                        let status = todayCards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: todayCards)
                        return .setHistoryCardsWithStatus(mockCards, status)
                    }
                }
            
        case .fetchWeeklyCards(let startDate, let endDate):
            return cardUseCase.fetchWeeklyCards(startDate: startDate, endDate: endDate)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        print("주간 카드 패치 완료")
                        CardService.shared.saveWeeklyCards(cards)
                        UserdefaultKey.lastWeeklyCardDate = endDate.toDate()
                        let todayCards = CardService.shared.getTodayCards()
                        return .just(.setTodayCards(todayCards))
                    case .failure:
                        let mockCards = MockCardData.dailyCards
                        let today = Date()
                        let calendar = Calendar.current
                        let todayCards = mockCards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                        return .just(.setTodayCards(todayCards))
//                        return .just(.setError(error))
                    }
                }
        case .loadTodayCards:
            let todayString = CardService.shared.getCardSystemDate().toYYYYMMDD()
            return cardUseCase.fetchWeeklyCards(startDate: todayString, endDate: todayString)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        print("✅ 오늘 카드 서버 패치 완료: \(cards.count)개")
                        let status = cards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: cards)
                        return .concat([
                            .just(.setTodayCards(cards)),
                            .just(.setAnswerStatus(status))
                        ])
                    case .failure:
                        print("⚠️ 서버 실패 - 로컬 주간 카드 확인")
                        let savedTodayCards = CardService.shared.getTodayCards()
                        print("💾 로컬 저장된 오늘 카드: \(savedTodayCards.count)개")
                        
                        if savedTodayCards.isEmpty {
                            print("🔄 Mock 데이터 사용")
                            let mockCards = MockCardData.dailyCards
                            let today = Date()
                            let calendar = Calendar.current
                            let todayCards = mockCards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                            print("📦 Mock 오늘 카드: \(todayCards.count)개")
                            let status = todayCards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: todayCards)
                            return .concat([
                                .just(.setTodayCards(todayCards)),
                                .just(.setAnswerStatus(status))
                            ])
                        }
                        
                        let status = savedTodayCards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: savedTodayCards)
                        return .concat([
                            .just(.setTodayCards(savedTodayCards)),
                            .just(.setAnswerStatus(status))
                        ])
                    }
                }
        case .assignCards:
            let today = Date()
            let calendar = Calendar.current
            guard let nextSunday = calendar.nextDate(after: today, matching: DateComponents(weekday: 1), matchingPolicy: .nextTime) else {
                return .empty()
            }
            
            let startDate = today.toYYYYMMDD()
            let endDate = nextSunday.toYYYYMMDD()
            
            return cardUseCase.assignCards(startDate: startDate, endDate: endDate)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success:
                        print("✅ 카드 할당 완료")
                        return .empty()
                    case .failure(let error):
                        print("⚠️ 카드 할당 실패: \(error)")
                        return .empty()
                    }
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAnswerStatus(let status):
            newState.answerStatus = status
        case .setPoked(let isPoked):
            newState.isPoked = isPoked
        case .setShowNotificationAlert(let show):
            newState.shouldShowNotificationAlert = show
        case .setCoupleConnected(let connected):
            newState.isCoupleConnected = connected
        case .setHistoryCards(let cards):
            newState.historyCards = cards
        case .setHistoryCardsWithStatus(let cards, let status):
            newState.historyCards = cards
            newState.answerStatus = status
        case .setTodayCards(let cards):
            newState.todayCards = cards
        case .setError:
            break
        }
        return newState
    }
}
