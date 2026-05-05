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

enum CardLoadState {
    case loading
    case loaded
    case retryable   // 데일리카드 조회 성공했지만 빈값
    case error       // API 실패 or 재조회 실패
}

final class HomeReactor: Reactor {
    
    private let cardUseCase: CardUseCase
    private let loginUseCase: LoginUseCase
    private let coupleUseCase: CoupleUseCase
    
    init(cardUseCase: CardUseCase, loginUseCase: LoginUseCase, coupleUseCase: CoupleUseCase) {
        self.cardUseCase = cardUseCase
        self.loginUseCase = loginUseCase
        self.coupleUseCase = coupleUseCase
    }
    
    enum Action {
        case updateAnswerStatus(AnswerStatus)
        case tapPokeButton(coupleCardId: Int)
        case tapConnectCoupleButton
        case checkFirstLaunch
        case dismissNotificationAlert
        case dismissPokeError
        case dismissPokeSuccess
        case fetchHistoryCards(startDate: String, endDate: String)
        case fetchWeeklyCards(startDate: String, endDate: String)
        case loadTodayCards
        case assignCards
        case notiAgree
        case checkCoupleConnection
        case retryFetchCards
        case initialLoad
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
        case setShowTooltip(Bool)
        case setShowPokeError(Bool)
        case setWeeklyCardsFetchFailed(Bool)
        case setDidPokeSuccess(Bool)
        case setCardLoadState(CardLoadState)
    }
    
    struct State {
        var answerStatus: AnswerStatus = .bothUnanswered
        var isPoked: Bool = UserdefaultKey.lastPokeDate == CardService.shared.getCardSystemDate().toYYYYMMDD()
        var shouldShowNotificationAlert: Bool = true
        var isCoupleConnected: Bool = UserdefaultKey.coupleType == .connected
        var historyCards: [QuestionCard] = []
        var todayCards: [QuestionCard] = []
        var shouldShowTooltip: Bool = false
        var shouldShowPokeError: Bool = false
        var weeklyCardsFetchFailed: Bool = false
        @Pulse var didPokeSuccess: Bool = false
        @Pulse var cardLoadState: CardLoadState = .loading
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
        case .tapPokeButton(let coupleCardId):
            return cardUseCase.pokeDailyCard(coupleCardId: coupleCardId)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success:
                        print("✅ 콕찌르기 성공")
                        UserdefaultKey.lastPokeDate = CardService.shared.getCardSystemDate().toYYYYMMDD()
                        return .concat([
                            .just(.setPoked(true)),
                            .just(.setDidPokeSuccess(true))
                        ])
                    case .failure(let error):
                        print("⚠️ 콕찌르기 실패: \(error)")
                        return .just(.setShowPokeError(true))
                    }
                }
        case .tapConnectCoupleButton:
            return .just(.setCoupleConnected(UserdefaultKey.coupleType == .connected))
        case .checkFirstLaunch:
            return .just(.setShowNotificationAlert(true))
        case .dismissNotificationAlert:
            return .just(.setShowNotificationAlert(false))
        case .dismissPokeError:
            return .just(.setShowPokeError(false))
        case .dismissPokeSuccess:
            return .just(.setDidPokeSuccess(false))
        case .fetchHistoryCards(let startDate, let endDate):
            return cardUseCase.fetchHistoryCards(startDate: startDate, endDate: endDate)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        let today = CardService.shared.getCardSystemDate()
                        let calendar = Calendar.current
                        let todayCards = cards.filter { calendar.isDate($0.date, inSameDayAs: today) }
                        let status = todayCards.isEmpty ? .bothUnanswered : self.determineAnswerStatus(from: todayCards)
                        
                        let todayString = today.toYYYYMMDD()
                        let shouldShow = status == .bothAnswered && UserdefaultKey.lastTooltipShownDate != todayString
                        
                        if shouldShow {
                            UserdefaultKey.lastTooltipShownDate = todayString
                        }
                        
                        let isPoked = (todayCards.first?.pocked ?? false) || UserdefaultKey.lastPokeDate == todayString
                        
                        return .concat([
                            .just(.setHistoryCardsWithStatus(cards, status)),
                            .just(.setShowTooltip(shouldShow)),
                            .just(.setPoked(isPoked))
                        ])
                    case .failure:
                        return self.loginUseCase.fetchUserInfo()
                            .flatMap { userInfo -> Observable<Mutation> in
                                if userInfo.coupleType != .connected {
                                    NotificationCenter.default.post(name: .logoutRequired, object: nil)
                                }
                                return .just(.setHistoryCardsWithStatus([], .bothUnanswered))
                            }
                            .catch { _ in
                                .just(.setHistoryCardsWithStatus([], .bothUnanswered))
                            }
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
                        if todayCards.isEmpty {
                            return .just(.setCardLoadState(.retryable))
                        }
                        let status = self.determineAnswerStatus(from: todayCards)
                        return .concat([
                            .just(.setCardLoadState(.loaded)),
                            .just(.setWeeklyCardsFetchFailed(false)),
                            .just(.setTodayCards(todayCards)),
                            .just(.setAnswerStatus(status))
                        ])
                    case .failure:
                        return .just(.setCardLoadState(.error))
                    }
                }
            
        case .loadTodayCards:
            let savedTodayCards = CardService.shared.getTodayCards()
            if savedTodayCards.isEmpty {
                return .just(.setCardLoadState(.retryable))
            }
            let status = self.determineAnswerStatus(from: savedTodayCards)
            return .concat([
                .just(.setCardLoadState(.loaded)),
                .just(.setTodayCards(savedTodayCards)),
                .just(.setAnswerStatus(status))
            ])
            
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
        case .notiAgree:
            return cardUseCase.notiAgree()
                .flatMap { _ -> Observable<Mutation> in
                    return .empty()
                }
                .catch { error in
                    return .just(.setError(error))
                }
        case .checkCoupleConnection:
            guard currentState.isCoupleConnected == false else { return .empty() }
            return loginUseCase.fetchUserInfo()
                .flatMap { userInfo -> Observable<Mutation> in
                    return .just(.setCoupleConnected(userInfo.coupleType == .connected))
                }
                .catch { _ in .empty() }
            
        case .initialLoad:
            let today = CardService.shared.getCardSystemDate()
            let calendar = Calendar.current
            
            // 주간 카드 날짜 범위
            let savedTodayCards = CardService.shared.getTodayCards()
            let needsWeeklyFetch: Bool = {
                guard let lastWeeklyDate = UserdefaultKey.lastWeeklyCardDate,
                      lastWeeklyDate >= Date(),
                      !savedTodayCards.isEmpty else { return true }
                return false
            }()
            
            // 히스토리 카드 날짜 범위
            var histCal = Calendar.current
            histCal.firstWeekday = 2
            let histComponents = histCal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
            let histStart = histCal.date(from: histComponents)?.toYYYYMMDD() ?? today.toYYYYMMDD()
            let histEnd = today.toYYYYMMDD()
            
            // 주간 카드 Observable
            let weeklyObs: Observable<Result<[QuestionCard], Error>>
            if needsWeeklyFetch {
                guard let nextSunday = calendar.nextDate(after: today, matching: DateComponents(weekday: 1), matchingPolicy: .nextTime) else {
                    return .just(.setCardLoadState(.retryable))
                }
                let wStart = today.toYYYYMMDD()
                let wEnd = nextSunday.toYYYYMMDD()
                weeklyObs = cardUseCase.fetchWeeklyCards(startDate: wStart, endDate: wEnd)
                    .map { result -> Result<[QuestionCard], Error> in
                        switch result {
                        case .success(let cards):
                            CardService.shared.saveWeeklyCards(cards)
                            UserdefaultKey.lastWeeklyCardDate = wEnd.toDate()
                            return .success(cards)
                        case .failure(let error):
                            return .failure(error)
                        }
                    }
            } else {
                weeklyObs = .just(.success(savedTodayCards))
            }
            
            // 히스토리 카드 Observable
            let historyObs = cardUseCase.fetchHistoryCards(startDate: histStart, endDate: histEnd)
                .map { result -> Result<[QuestionCard], Error> in
                    switch result {
                    case .success(let cards): return .success(cards)
                    case .failure(let error): return .failure(error)
                    }
                }
                .catchAndReturn(.success([]))
            
            return Observable.zip(weeklyObs, historyObs)
                .flatMap { [weak self] weeklyResult, historyResult -> Observable<Mutation> in
                    guard let self else { return .empty() }
                    var mutations: [Observable<Mutation>] = []
                    
                    // 히스토리 카드 처리
                    let historyCards: [QuestionCard]
                    switch historyResult {
                    case .success(let cards):
                        historyCards = cards
                    case .failure:
                        historyCards = []
                    }
                    
                    let todayString = today.toYYYYMMDD()
                    let todayHistoryCards = historyCards.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
                    let historyStatus = todayHistoryCards.isEmpty ? AnswerStatus.bothUnanswered : self.determineAnswerStatus(from: todayHistoryCards)
                    let shouldShowTooltip = historyStatus == .bothAnswered && UserdefaultKey.lastTooltipShownDate != todayString
                    if shouldShowTooltip { UserdefaultKey.lastTooltipShownDate = todayString }
                    let isPoked = (todayHistoryCards.first?.pocked ?? false) || UserdefaultKey.lastPokeDate == todayString
                    
                    mutations.append(.just(.setHistoryCardsWithStatus(historyCards, historyStatus)))
                    mutations.append(.just(.setShowTooltip(shouldShowTooltip)))
                    mutations.append(.just(.setPoked(isPoked)))
                    
                    // 주간 카드 처리
                    switch weeklyResult {
                    case .success:
                        let todayCards = CardService.shared.getTodayCards()
                        if todayCards.isEmpty {
                            mutations.append(.just(.setCardLoadState(.retryable)))
                        } else {
                            let status = self.determineAnswerStatus(from: todayCards)
                            mutations.append(.just(.setCardLoadState(.loaded)))
                            mutations.append(.just(.setTodayCards(todayCards)))
                            mutations.append(.just(.setAnswerStatus(status)))
                        }
                    case .failure:
                        mutations.append(.just(.setCardLoadState(.retryable)))
                    }
                    
                    return .concat(mutations)
                }
            
        case .retryFetchCards:
            let today = CardService.shared.getCardSystemDate()
            let calendar = Calendar.current
            guard let nextSunday = calendar.nextDate(after: today, matching: DateComponents(weekday: 1), matchingPolicy: .nextTime) else {
                return .just(.setCardLoadState(.error))
            }
            let startDate = today.toYYYYMMDD()
            let endDate = nextSunday.toYYYYMMDD()
            return coupleUseCase.assignCards(startDate: startDate, endDate: endDate)
                    .flatMap { [weak self] _ -> Observable<Mutation> in
                        guard let self else { return .just(.setCardLoadState(.error)) }
                        return self.cardUseCase.fetchWeeklyCards(startDate: startDate, endDate: endDate)
                            .flatMap { result -> Observable<Mutation> in
                                switch result {
                                case .success(let cards):
                                    CardService.shared.saveWeeklyCards(cards)
                                    UserdefaultKey.lastWeeklyCardDate = endDate.toDate()
                                    let todayCards = CardService.shared.getTodayCards()
                                    if todayCards.isEmpty {
                                        return .just(.setCardLoadState(.error))
                                    }
                                    let status = self.determineAnswerStatus(from: todayCards)
                                    return .concat([
                                        .just(.setCardLoadState(.loaded)),
                                        .just(.setTodayCards(todayCards)),
                                        .just(.setAnswerStatus(status))
                                    ])
                                case .failure:
                                    return .just(.setCardLoadState(.error))
                                }
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
        case .setShowTooltip(let show):
            newState.shouldShowTooltip = show
        case .setShowPokeError(let show):
            newState.shouldShowPokeError = show
        case .setWeeklyCardsFetchFailed(let failed):
            newState.weeklyCardsFetchFailed = failed
        case .setDidPokeSuccess(let success):
            newState.didPokeSuccess = success
        case .setCardLoadState(let state):
            newState.cardLoadState = state
        }
        return newState
    }
}
