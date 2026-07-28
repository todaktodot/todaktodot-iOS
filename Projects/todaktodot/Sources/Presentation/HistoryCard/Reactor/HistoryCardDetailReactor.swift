//
//  HistoryCardDetailReactor.swift
//  todaktodot
//
//  Created by daye on 3/24/26.
//

import Foundation
import ReactorKit
import RxSwift
import NetworkKit

final class HistoryCardDetailReactor: Reactor {
    
    // 히스토리카드 업데이트 타이밍때문에 피드백 두번 로딩할때가 있어서 만들어둠
    private static var feedbackCache: [Int: CardFeedback] = [:]
    private static var feedbackCacheOrder: [Int] = []
    private static let maxCacheSize = 7
    
    private static var weekKey: String {
        (UserdefaultKey.lastWeeklyCardDate ?? CardService.shared.getCardSystemDate()).toYYYYMMDD()
    }
    
    private static func hasAction(_ action: String, for date: String) -> Bool {
        UserdefaultKey.feedbackActionHistory["week_\(weekKey)"]?[date]?.contains(action) ?? false
    }
    
    private static func markAction(_ action: String, for date: String) {
        var history = UserdefaultKey.feedbackActionHistory
        let key = "week_\(weekKey)"
        var week = history[key] ?? [:]
        var actions = week[date] ?? []
        guard !actions.contains(action) else { return }
        actions.append(action)
        week[date] = actions
        history[key] = week
        history.keys.filter { $0 != key }.forEach { history.removeValue(forKey: $0) }
        UserdefaultKey.feedbackActionHistory = history
    }
    
    static func hasPolled(for date: String) -> Bool {
        hasAction("polled", for: date)
    }
    
    static func hasRegenerated(for date: String) -> Bool {
        hasAction("regenerated", for: date)
    }
    
    static func markPolled(for date: String) {
        markAction("polled", for: date)
    }
    
    static func markRegenerated(for date: String) {
        markAction("regenerated", for: date)
    }
    
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
    private let shareLinkUseCase: ShareLinkUseCase
    private let pollingInterval: RxTimeInterval = .seconds(3)
    
    enum FeedbackState {
        case none
        case locked
        case generating
        case loaded(CardFeedback)
        case retryable
        case error
    }

    enum Action {
        case checkFeedback
        case regenerate
        case saveEmoji(EmojiType)
        case deleteEmoji
        case refreshPartnerEmoji
        case createShareLink
    }
    
    enum Mutation {
        case setFeedbackState(FeedbackState)
        case setEmoji(EmojiType?)
        case setPartnerEmoji(EmojiType?)
        case setShareURL(String)
        case setShareError
    }
    
    struct State {
        var card: QuestionCard
        @Pulse var feedbackState: FeedbackState
        @Pulse var myEmoji: EmojiType?
        @Pulse var partnerEmoji: EmojiType?
        @Pulse var shareURL: String?
        @Pulse var shareError: Bool?
    }
    
    let initialState: State
    
    init(cardUseCase: CardUseCase, shareLinkUseCase: ShareLinkUseCase, card: QuestionCard) {
        self.cardUseCase = cardUseCase
        self.shareLinkUseCase = shareLinkUseCase
        
        let id = card.coupleCardId
        let initialFeedback: FeedbackState
        
        if let feedback = card.feedback {
            initialFeedback = .loaded(feedback)
        } else if let cached = Self.feedbackCache[id] {
            initialFeedback = .loaded(cached)
        } else if !card.isBothAnswered {
            initialFeedback = .locked
        } else if Self.hasRegenerated(for: card.date.toYYYYMMDD()) {
            initialFeedback = .error
        } else if Self.hasPolled(for: card.date.toYYYYMMDD()) {
            initialFeedback = .retryable
        } else {
            initialFeedback = .generating
        }
        
        self.initialState = State(
            card: card,
            feedbackState: initialFeedback,
            myEmoji: card.questions.first(where: { $0.type == .multipleChoice })?.user2Emoji,
            partnerEmoji: card.questions.first(where: { $0.type == .multipleChoice })?.user1Emoji,
            shareURL: nil,
            shareError: nil
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .checkFeedback:
            guard case .generating = currentState.feedbackState else { return .empty() }
            let coupleCardId = currentState.card.coupleCardId
            let date = currentState.card.date.toYYYYMMDD()
            Self.markPolled(for: date)
            return pollFeedback(coupleCardId: coupleCardId, fallback: .retryable)
            
        case .regenerate:
            let card = currentState.card
            let issuedDate = card.date.toYYYYMMDD()
            return Observable.concat(
                .just(.setFeedbackState(.generating)),
                cardUseCase.generateFeedback(coupleCardId: card.coupleCardId, cardId: card.id, issuedDate: issuedDate)
                    .flatMap { [weak self] result -> Observable<Mutation> in
                        guard let self else { return .empty() }
                        Self.markRegenerated(for: issuedDate)
                        switch result {
                        case .success:
                            return self.pollFeedback(coupleCardId: card.coupleCardId, fallback: .error)
                        case .failure(let error):
                            let afErr = error as? CustomAFError
                            let code = afErr?.statusCode.map { "\($0)" } ?? "unknown"
                            let msg = afErr?.message ?? error.localizedDescription
                            Self.sendWebhook(card: card, reason: "API 호출 실패", statusCode: code, message: msg)
                            return .just(.setFeedbackState(.error))
                        }
                    }
            )
            
        case .saveEmoji(let emojiType):
            guard isCurrentWeek(card: currentState.card) else { return .empty() }
            let coupleCardId = currentState.card.coupleCardId
            return Observable.concat(
                .just(.setEmoji(emojiType)),
                cardUseCase.saveEmoji(coupleCardId: coupleCardId, emojiType: emojiType)
                    .flatMap { _ in Observable<Mutation>.empty() }
            )
            
        case .deleteEmoji:
            guard isCurrentWeek(card: currentState.card) else { return .empty() }
            let coupleCardId = currentState.card.coupleCardId
            return Observable.concat(
                .just(.setEmoji(nil)),
                cardUseCase.deleteEmoji(coupleCardId: coupleCardId)
                    .flatMap { _ in Observable<Mutation>.empty() }
            )
            
        case .refreshPartnerEmoji:
            let card = currentState.card
            let dateStr = card.date.toYYYYMMDD()
            return cardUseCase.fetchHistoryCards(startDate: dateStr, endDate: dateStr)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let cards):
                        let matched = cards.first(where: { $0.coupleCardId == card.coupleCardId })
                        let emoji = matched?.questions.first(where: { $0.type == .multipleChoice })?.user1Emoji
                        return .just(.setPartnerEmoji(emoji))
                    case .failure:
                        return .empty()
                    }
                }
            
        case .createShareLink:
            let coupleCardId = currentState.card.coupleCardId
            return shareLinkUseCase.createShareLink(coupleCardId: coupleCardId)
                .flatMap { result -> Observable<Mutation> in
                    switch result {
                    case .success(let shareLink):
                        return .just(.setShareURL(shareLink.shareUrl))
                    case .failure:
                        return .just(.setShareError)
                    }
                }
        }
    }
    
    private func pollFeedback(coupleCardId: Int, fallback: FeedbackState) -> Observable<Mutation> {
        return Observable<Int>.timer(pollingInterval, scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.cardUseCase.fetchFeedbackStatus(coupleCardId: coupleCardId)
                    .flatMap { [weak self] result -> Observable<Mutation> in
                        guard let self else { return .empty() }
                        switch result {
                        case .success(let statusResult):
                            switch statusResult.status {
                            case .completed:
                                if let feedback = statusResult.feedback {
                                    return .just(.setFeedbackState(.loaded(feedback)))
                                }
                                return .just(.setFeedbackState(fallback))
                            case .generating:
                                return .just(.setFeedbackState(fallback))
                            case .notStarted, .failed:
                                if case .error = fallback {
                                    Self.sendWebhook(card: self.currentState.card, reason: "단건 조회 상태: \(statusResult.status.rawValue)")
                                }
                                return .just(.setFeedbackState(fallback))
                            }
                        case .failure(let error):
                            if case .error = fallback {
                                let afErr = error as? CustomAFError
                                let code = afErr?.statusCode.map { "\($0)" } ?? "unknown"
                                let msg = afErr?.message ?? error.localizedDescription
                                Self.sendWebhook(card: self.currentState.card, reason: "API 실패", statusCode: code, message: msg)
                            }
                            return .just(.setFeedbackState(fallback))
                        }
                    }
            }
    }
    
    private static func sendWebhook(card: QuestionCard, reason: String, statusCode: String = "", message: String = "") {
        let date = card.date.toYYYYMMDD()
        guard !hasAction("webhook", for: date) else { return }
        markAction("webhook", for: date)
        
        WebhookManager.sendFeedbackError(
            reason: reason,
            coupleCardId: card.coupleCardId,
            cardId: card.id,
            issuedDate: date,
            statusCode: statusCode,
            message: message
        )
    }
    
    private func isCurrentWeek(card: QuestionCard) -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 월요일 시작
        let today = CardService.shared.getCardSystemDate()
        return calendar.isDate(card.date, equalTo: today, toGranularity: .weekOfYear)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFeedbackState(let feedbackState):
            newState.feedbackState = feedbackState
            if case .loaded(let feedback) = feedbackState {
                Self.cacheFeedback(feedback, for: state.card.coupleCardId)
            }
        case .setEmoji(let emoji):
            newState.myEmoji = emoji
        case .setPartnerEmoji(let emoji):
            newState.partnerEmoji = emoji
        case .setShareURL(let url):
            newState.shareURL = url
        case .setShareError:
            newState.shareError = true
        }
        return newState
    }
}
