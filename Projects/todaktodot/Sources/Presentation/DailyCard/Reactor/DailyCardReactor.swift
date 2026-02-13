//
//  DailyCardReactor.swift
//  todaktodot
//
//  Created by daye on 12/16/25.
//

import ReactorKit
import RxSwift

final class DailyCardReactor: Reactor {
    
    private let cardUseCase: CardUseCase
    private let dailyCards: [QuestionCard]
    
    init(cardUseCase: CardUseCase, dailyCards: [QuestionCard]) {
        self.cardUseCase = cardUseCase
        self.dailyCards = dailyCards
        
        if dailyCards.count == 1 {
            self.initialState = State(selectedCardType: dailyCards.first?.type)
        } else {
            self.initialState = State()
        }
    }
    
    enum Action {
        case tapBackButton
        case tapSituationButton
        case tapBalanceButton
    }
    
    enum Mutation {
        case setDismiss(Bool)
        case navigateToDetail(CardType)
    }
    
    struct State {
        var shouldDismiss: Bool = false
        var selectedCardType: CardType?
    }
    
    let initialState: State
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapBackButton:
            return .just(.setDismiss(true))
        case .tapSituationButton:
            return .just(.navigateToDetail(.roleplay))
        case .tapBalanceButton:
            return .just(.navigateToDetail(.balance))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDismiss(let shouldDismiss):
            newState.shouldDismiss = shouldDismiss
        case .navigateToDetail(let cardType):
            newState.selectedCardType = cardType
        }
        return newState
    }
}
