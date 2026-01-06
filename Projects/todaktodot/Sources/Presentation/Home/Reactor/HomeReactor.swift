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
    
    enum Action {
        case updateAnswerStatus(AnswerStatus)
        case tapPokeButton
        case checkFirstLaunch
        case dismissNotificationAlert
    }
    
    enum Mutation {
        case setAnswerStatus(AnswerStatus)
        case setPoked(Bool)
        case setShowNotificationAlert(Bool)
    }
    
    struct State {
        var answerStatus: AnswerStatus = .myAnswered
        var isPoked: Bool = false
        var shouldShowNotificationAlert: Bool = true
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateAnswerStatus(let status):
            return .just(.setAnswerStatus(status))
        case .tapPokeButton:
            // TODO: 서버연결
            return .just(.setPoked(true))
        case .checkFirstLaunch:
            // TODO: 최초 실행 여부 확인
            return .just(.setShowNotificationAlert(true))
        case .dismissNotificationAlert:
            return .just(.setShowNotificationAlert(false))
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
        }
        return newState
    }
}
