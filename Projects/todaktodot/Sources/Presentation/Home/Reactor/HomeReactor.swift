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
    }
    
    enum Mutation {
        case setAnswerStatus(AnswerStatus)
        case setPoked(Bool)
        case setShowNotificationAlert(Bool)
        case setCoupleConnected(Bool)
        case setHistoryCards([QuestionCard])
        case setTodayCards([QuestionCard])
        case setError(Error)
    }
    
    struct State {
        var answerStatus: AnswerStatus = .bothUnanswered
        var isPoked: Bool = false
        var shouldShowNotificationAlert: Bool = true
        var isCoupleConnected: Bool = false
        var historyCards: [QuestionCard] = []
        var todayCards: [QuestionCard] = []
    }
    
    let initialState = State()

    private func determineAnswerStatus(from cards: [QuestionCard]) -> AnswerStatus {
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
            // TODO: 서버연결 - 콕 찌르기
            return .just(.setPoked(true))
        case .tapConnectCoupleButton:
            // TODO: 서버연결 - 커플 연결
            return .just(.setCoupleConnected(true))
        case .checkFirstLaunch:
            // TODO: 최초 실행 여부 확인
            return .just(.setShowNotificationAlert(true))
        case .dismissNotificationAlert:
            return .just(.setShowNotificationAlert(false))
        case .fetchHistoryCards(let startDate, let endDate):
            return cardUseCase.fetchHistoryCards(startDate: startDate, endDate: endDate)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        // TODO: 오늘 조회된 카드 없으면 둘 다 대답하지 않은것으로 지정. 확인필요. 해당 로직이면 카드 없을때 오늘 UI용 더미카드 만들어줘야함
                        let today = Date()
                        let calendar = Calendar.current
                        let todayCards = cards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                        let status = todayCards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: todayCards)
                        return .concat([
                            .just(.setHistoryCards(cards)),
                            .just(.setAnswerStatus(status))
                        ])
                    case .failure(let error):
                        let mockCards = MockCardData.historyCards
                        let today = Date()
                        let calendar = Calendar.current
                        let todayCards = mockCards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                        let status = todayCards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: todayCards)
                        return .concat([
                            .just(.setHistoryCards(mockCards)),
                            .just(.setAnswerStatus(status))
                        ])
//                        return .just(.setError(error))
                    }
                }
            
        case .fetchWeeklyCards(let startDate, let endDate):
            return cardUseCase.fetchWeeklyCards(startDate: startDate, endDate: endDate)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        print("주간 카드 패치 완료")
                        CardStorageService.shared.saveWeeklyCards(cards)
                        UserdefaultKey.lastWeeklyCardDate = endDate.toDate()
                        let todayCards = CardStorageService.shared.getTodayCards()
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
            let todayString = Date().toYYYYMMDD()
            return cardUseCase.fetchWeeklyCards(startDate: todayString, endDate: todayString)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        print("✅ 오늘 카드 패치 완료: \(cards.count)개")
                        return .just(.setTodayCards(cards))
                    case .failure:
                        print("⚠️ 서버 실패 - 저장된 카드 확인")
                        let savedTodayCards = CardStorageService.shared.getTodayCards()
                        print("💾 저장된 카드: \(savedTodayCards.count)개")
                        
                        if savedTodayCards.isEmpty {
                            print("🔄 Mock 데이터 사용")
                            let mockCards = MockCardData.dailyCards
                            let today = Date()
                            let calendar = Calendar.current
                            let todayCards = mockCards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                            print("📦 Mock 오늘 카드: \(todayCards.count)개")
                            return .just(.setTodayCards(todayCards))
                        }
                        
                        return .just(.setTodayCards(savedTodayCards))
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
        case .setTodayCards(let cards):
            newState.todayCards = cards
        case .setError:
            break
        }
        return newState
    }
}
