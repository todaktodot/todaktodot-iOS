//
//  HistoryCardDetailReactor.swift
//  todaktodot
//
//  Created by daye on 3/24/26.
//

import ReactorKit
import RxSwift

final class HistoryCardDetailReactor: Reactor {
    
    // 히스토리카드 업데이트 타이밍때문에 피드백 두번 로딩할때가 있어서 만들어둠
    private static var feedbackCache: [Int: CardFeedback] = [:]
    private static var feedbackCacheOrder: [Int] = []
    private static let maxCacheSize = 7
    
    static func cachedFeedback(for coupleCardId: Int) -> CardFeedback? {
        feedbackCache[coupleCardId]
    }
    
    private static func cacheFeedback(_ feedback: CardFeedback, for coupleCardId: Int) {
        feedbackCache[coupleCardId] = feedback
        feedbackCacheOrder.removeAll { $0 == coupleCardId }
        feedbackCacheOrder.append(coupleCardId)
        if feedbackCacheOrder.count > maxCacheSize {
            let removed = feedbackCacheOrder.removeFirst()
            feedbackCache.removeValue(forKey: removed)
        }
    }
    
    private let cardUseCase: CardUseCase
    private let maxRetryCount = 3
    private let pollingInterval: RxTimeInterval = .seconds(5)
    
    enum FeedbackState {
        case none
        case generating
        case loaded(CardFeedback)
        case error
    }

    enum Action {
        case checkFeedback
    }
    
    enum Mutation {
        case setFeedbackState(FeedbackState)
    }
    
    struct State {
        var card: QuestionCard
        @Pulse var feedbackState: FeedbackState
    }
    
    let initialState: State
    
    init(cardUseCase: CardUseCase, card: QuestionCard) {
        self.cardUseCase = cardUseCase
        
        let initialFeedback: FeedbackState
        if let feedback = card.feedback {
            initialFeedback = .loaded(feedback)
        } else if let cached = Self.feedbackCache[card.coupleCardId] {
            initialFeedback = .loaded(cached)
        } else if card.isBothAnswered {
            initialFeedback = .generating
        } else {
            initialFeedback = .none
        }
        
        self.initialState = State(card: card, feedbackState: initialFeedback)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkFeedback:
            guard case .generating = currentState.feedbackState else { return .empty() }
            
            let coupleCardId = currentState.card.coupleCardId
            
            return Observable<Int>.interval(pollingInterval, scheduler: MainScheduler.instance)
                .take(maxRetryCount)
                .flatMapLatest { [weak self] _ -> Observable<Mutation> in
                    guard let self else { return .empty() }
                    return self.cardUseCase.fetchHistoryCardDetail(coupleCardId: coupleCardId)
                        .flatMap { result -> Observable<Mutation> in
                            switch result {
                            case .success(let card):
                                if let feedback = card.feedback {
                                    return .just(.setFeedbackState(.loaded(feedback)))
                                }
                                return .empty()
                            case .failure:
                                return .just(.setFeedbackState(.error))
                            }
                        }
                }
                .take(until: { mutation in
                    if case .setFeedbackState(.loaded) = mutation { return true }
                    if case .setFeedbackState(.error) = mutation { return true }
                    return false
                }, behavior: .inclusive)
                .concat(Observable.deferred { [weak self] in
                    guard let self else { return .empty() }
                    if case .generating = self.currentState.feedbackState {
                        return .just(.setFeedbackState(.error))
                    }
                    return .empty()
                })
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFeedbackState(let feedbackState):
            newState.feedbackState = feedbackState
            if case .loaded(let feedback) = feedbackState {
                Self.cacheFeedback(feedback, for: state.card.coupleCardId)
            }
        }
        return newState
    }
}
