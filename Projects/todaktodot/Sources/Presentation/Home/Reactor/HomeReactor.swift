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
        var answerStatus: AnswerStatus = .myAnswered
        var isPoked: Bool = false
        var shouldShowNotificationAlert: Bool = true
        var isCoupleConnected: Bool = false
        var historyCards: [QuestionCard] = []
        var todayCards: [QuestionCard] = []
    }
    
    let initialState = State()
    
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
                        return .just(.setHistoryCards(cards))
                    case .failure(let error):
                        return .just(.setHistoryCards(MockCardData.historyCards))
//                        return .just(.setError(error))
                    }
                }
        case .fetchWeeklyCards(let startDate, let endDate):
            return cardUseCase.fetchWeeklyCards(startDate: startDate, endDate: endDate)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        CardStorageService.shared.saveWeeklyCards(cards)
                        UserdefaultKey.lastWeeklyCardDate = endDate.toDate()
                        let todayCards = CardStorageService.shared.getTodayCards()
                        return .just(.setTodayCards(todayCards))
                    case .failure(let error):
                        return .just(.setError(error))
                    }
                }
        case .loadTodayCards:
            let todayString = Date().toYYYYMMDD()
            return cardUseCase.fetchWeeklyCards(startDate: todayString, endDate: todayString)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        return .just(.setTodayCards(cards))
                    case .failure:
                        let savedTodayCards = CardStorageService.shared.getTodayCards()
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
