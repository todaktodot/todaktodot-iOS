//
//  HomeReactor.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import ReactorKit
import RxSwift

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
    }
    
    enum Mutation {
        case setAnswerStatus(AnswerStatus)
        case setPoked(Bool)
        case setShowNotificationAlert(Bool)
        case setCoupleConnected(Bool)
        case setHistoryCards([QuestionCard])
        case setError(Error)
    }
    
    struct State {
        var answerStatus: AnswerStatus = .myAnswered
        var isPoked: Bool = false
        var shouldShowNotificationAlert: Bool = true
        var isCoupleConnected: Bool = false
        var historyCards: [QuestionCard] = []
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
        case .setError:
            break
        }
        return newState
    }
}
