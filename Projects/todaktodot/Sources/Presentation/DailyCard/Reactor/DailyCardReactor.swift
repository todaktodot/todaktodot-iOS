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
    private let historySelectedType: CardType  // 히스토리 카드에서 선택된 타입
    let onCardSelected = PublishSubject<Void>()
    
    init(cardUseCase: CardUseCase, dailyCards: [QuestionCard], selectedType: CardType) {
        self.cardUseCase = cardUseCase
        self.dailyCards = dailyCards
        self.historySelectedType = selectedType  // 히스토리 선택 타입 저장
        
        // 초기 상태는 히스토리 선택 타입으로 설정
        self.initialState = State(historySelectedType: selectedType)
    }
    
    enum Action {
        case tapBackButton
        case tapSituationButton
        case tapBalanceButton
        case selectCardType(coupleCardId: Int, cardType: CardType)
        case submitAnswers(coupleCardId: Int, cardId: Int, answers: [Answer])
    }
    
    enum Mutation {
        case setDismiss(Bool)
        case navigateToDetail(QuestionCard)
        case setLoading(Bool)
        case setSubmitSuccess(SubmitAnswerResult)
        case setSubmitError(Error)
        case setCardTypeSelected(CardType)
        case setShouldRetryAndGoHome
        case setCardTypeSelectionError
    }
    
    struct State {
        var shouldDismiss: Bool = false
        var historySelectedType: CardType  // 히스토리에서 선택된 타입 (UI 표시용)
        var selectedCardType: CardType?    // 현재 선택된 타입 (로직 판별용)
        var selectedCard: QuestionCard?
        var isLoading: Bool = false
        var submitResult: SubmitAnswerResult?
        var submitError: Error?
        var shouldRetryAndGoHome: Bool = false
        var shouldShowAlreadySelectedAlert: Bool = false
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
            return .just(.navigateToDetail(card))
        case .tapBalanceButton:
            guard let card = dailyCards.first(where: { $0.type == .balance }) else {
                return .empty()
            }
            return .just(.navigateToDetail(card))
        case .selectCardType(let coupleCardId, let cardType):
            let targetCard = dailyCards.first(where: { $0.type == cardType })
            return Observable.concat([
                .just(.setLoading(true)),
                cardUseCase.selectCardType(coupleCardId: coupleCardId)
                    .flatMap { result -> Observable<Mutation> in
                        switch result {
                        case .success:
                            if let card = targetCard {
                                return .just(.navigateToDetail(card))
                            }
                            return .just(.setCardTypeSelected(cardType))
                        case .failure(let error):
//                            let errorMessage = error.localizedDescription
//                            if errorMessage.contains("이미 유형이 선택된") || errorMessage.contains("400") {
//                                return .just(.setCardTypeSelectionError)
//                            }
                            return .just(.setShouldRetryAndGoHome)
                        }
                    },
                .just(.setLoading(false))
            ])
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
        case .setCardTypeSelected(let cardType):
            newState.historySelectedType = cardType
        case .setShouldRetryAndGoHome:
            newState.shouldRetryAndGoHome = true
        case .setCardTypeSelectionError:
            newState.shouldShowAlreadySelectedAlert = true
        }
        return newState
    }
}

