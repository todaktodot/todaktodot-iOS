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
    let onCardSelected = PublishSubject<Void>()
    
    init(cardUseCase: CardUseCase, dailyCards: [QuestionCard]) {
        self.cardUseCase = cardUseCase
        self.dailyCards = dailyCards
        
        // 이미 선택된 카드가 있으면 초기 상태 설정
        if let selectedCard = dailyCards.first(where: { $0.isSelected }) {
            self.initialState = State(selectedCardType: selectedCard.type, selectedCard: selectedCard)
        } else if dailyCards.count == 1, let card = dailyCards.first {
            self.initialState = State(selectedCardType: card.type, selectedCard: card)
        } else {
            self.initialState = State()
        }
    }
    
    enum Action {
        case tapBackButton
        case tapSituationButton
        case tapBalanceButton
        case submitAnswers(coupleCardId: Int, cardId: Int, answers: [Answer])
    }
    
    enum Mutation {
        case setDismiss(Bool)
        case navigateToDetail(QuestionCard)
        case setLoading(Bool)
        case setSubmitSuccess(SubmitAnswerResult)
        case setSubmitError(Error)
    }
    
    struct State {
        var shouldDismiss: Bool = false
        var selectedCardType: CardType?
        var selectedCard: QuestionCard?
        var isLoading: Bool = false
        var submitResult: SubmitAnswerResult?
        var submitError: Error?
    }
    
    let initialState: State
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapBackButton:
            return .just(.setDismiss(true))
        case .tapSituationButton:
            guard let card = dailyCards.first(where: { $0.type == .roleplay }) else {
                return .empty()
            }
            return cardUseCase.selectCardType(coupleCardId: card.coupleCardId)
                .do(onNext: { [weak self] _ in
                    self?.onCardSelected.onNext(())
                })
                .flatMap { _ in Observable.just(Mutation.navigateToDetail(card)) }
        case .tapBalanceButton:
            guard let card = dailyCards.first(where: { $0.type == .balance }) else {
                return .empty()
            }
            return cardUseCase.selectCardType(coupleCardId: card.coupleCardId)
                .do(onNext: { [weak self] _ in
                    self?.onCardSelected.onNext(())
                })
                .flatMap { _ in Observable.just(Mutation.navigateToDetail(card)) }
        case .submitAnswers(let coupleCardId, let cardId, let answers):
            return Observable.concat([
                .just(.setLoading(true)),
                cardUseCase.submitAnswers(coupleCardId: coupleCardId, cardId: cardId, answers: answers)
                    .flatMap { result -> Observable<Mutation> in
                        switch result {
                        case .success(let submitResult):
                            return .just(.setSubmitSuccess(submitResult))
                        case .failure(let error):
                            return .just(.setSubmitError(error))
                        }
                    },
                .just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDismiss(let shouldDismiss):
            newState.shouldDismiss = shouldDismiss
        case .navigateToDetail(let card):
            newState.selectedCardType = card.type
            newState.selectedCard = card
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setSubmitSuccess(let result):
            newState.submitResult = result
            newState.submitError = nil
        case .setSubmitError(let error):
            newState.submitError = error
            newState.submitResult = nil
        }
        return newState
    }
}
