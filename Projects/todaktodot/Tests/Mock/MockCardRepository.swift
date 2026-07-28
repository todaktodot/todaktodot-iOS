//
//  MockCardRepository.swift
//  todaktodotTests
//
//  Created by daye on 7/28/26.
//

import Foundation
import RxSwift
@testable import todaktodot

final class MockCardRepository: CardRepository {
    
    var fetchWeeklyCardsResult: Observable<Result<[QuestionCard], Error>> = .just(.success([]))
    var fetchHistoryCardsResult: Observable<Result<[QuestionCard], Error>> = .just(.success([]))
    var selectCardTypeResult: Observable<Result<Void, Error>> = .just(.success(()))
    var assignCardsResult: Observable<Result<Void, Error>> = .just(.success(()))
    var submitAnswersResult: Observable<Result<SubmitAnswerResult, Error>> = .just(.success(SubmitAnswerResult(coupleCardId: 1, cardId: 1, userId: 1, savedCount: 1, savedAt: Date())))
    var pokeDailyCardResult: Observable<Result<Void, Error>> = .just(.success(()))
    var fetchHistoryCardDetailResult: Observable<Result<QuestionCard, Error>> = .just(.failure(NSError(domain: "", code: 0)))
    var notiAgreeResult: Observable<Bool> = .just(true)
    var generateFeedbackResult: Observable<Result<Void, Error>> = .just(.success(()))
    var fetchFeedbackStatusResult: Observable<Result<FeedbackStatusResult, Error>> = .just(.success(FeedbackStatusResult(status: .completed, feedback: nil)))
    var saveEmojiResult: Observable<Result<Void, Error>> = .just(.success(()))
    var deleteEmojiResult: Observable<Result<Void, Error>> = .just(.success(()))
    
    var generateFeedbackCallCount = 0
    var saveEmojiCallCount = 0
    var saveEmojiLastType: EmojiType?
    var deleteEmojiCallCount = 0
    var fetchFeedbackStatusCallCount = 0
    
    func fetchWeeklyCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>> { fetchWeeklyCardsResult }
    func fetchHistoryCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>> { fetchHistoryCardsResult }
    func selectCardType(coupleCardId: Int) -> Observable<Result<Void, Error>> { selectCardTypeResult }
    func assignCards(startDate: String, endDate: String) -> Observable<Result<Void, Error>> { assignCardsResult }
    func submitAnswers(coupleCardId: Int, cardId: Int, answers: [Answer]) -> Observable<Result<SubmitAnswerResult, Error>> { submitAnswersResult }
    func pokeDailyCard(coupleCardId: Int) -> Observable<Result<Void, Error>> { pokeDailyCardResult }
    func fetchHistoryCardDetail(coupleCardId: Int) -> Observable<Result<QuestionCard, Error>> { fetchHistoryCardDetailResult }
    func notiAgree() -> Observable<Bool> { notiAgreeResult }
    
    func generateFeedback(coupleCardId: Int, cardId: Int, issuedDate: String) -> Observable<Result<Void, Error>> {
        generateFeedbackCallCount += 1
        return generateFeedbackResult
    }
    
    func fetchFeedbackStatus(coupleCardId: Int) -> Observable<Result<FeedbackStatusResult, Error>> {
        fetchFeedbackStatusCallCount += 1
        return fetchFeedbackStatusResult
    }
    
    func saveEmoji(coupleCardId: Int, emojiType: EmojiType) -> Observable<Result<Void, Error>> {
        saveEmojiCallCount += 1
        saveEmojiLastType = emojiType
        return saveEmojiResult
    }
    
    func deleteEmoji(coupleCardId: Int) -> Observable<Result<Void, Error>> {
        deleteEmojiCallCount += 1
        return deleteEmojiResult
    }
}
