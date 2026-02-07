//
//  CardUseCase.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//


import Foundation
import RxSwift

final class CardUseCase {
    private let repository: CardRepository

    init(repository: CardRepository) {
        self.repository = repository
    }
    
    // 주간 데일리카드(user default 저장)
    func fetchWeeklyCards(startDate: String, endDate: String) -> Observable<[QuestionCard]> {
        repository.fetchWeeklyCards(startDate: startDate, endDate: endDate)
    }
    // 히스토리카드 전체
    func fetchHistoryCards(startDate: String, endDate: String) -> Observable<[QuestionCard]> {
        repository.fetchHistoryCards(startDate: startDate, endDate: endDate)
    }
    
    // 카드 유형 선택
    func selectCardType(coupleCardId: Int) -> Observable<Bool> {
        repository.selectCardType(coupleCardId: coupleCardId)
    }
    
    // 새로운 카드 배정하기
    func assignCards(startDate: String, endDate: String) -> Observable<Bool> {
        repository.assignCards(startDate: startDate, endDate: endDate)
    }
    
    // 답변 제출
    func submitAnswers(coupleCardId: Int, cardId: Int, answers: [AnswerInput]) -> Observable<Bool> {
        repository.submitAnswers(
            coupleCardId: coupleCardId, 
            cardId: cardId, 
            answers: answers
        )
    }
}
