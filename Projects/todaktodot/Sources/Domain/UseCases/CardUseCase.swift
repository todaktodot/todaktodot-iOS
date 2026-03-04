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
    
    func fetchWeeklyCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>> {
        repository.fetchWeeklyCards(startDate: startDate, endDate: endDate)
    }
    
    func fetchHistoryCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>> {
        repository.fetchHistoryCards(startDate: startDate, endDate: endDate)
    }
    
    func selectCardType(coupleCardId: Int) -> Observable<Result<Void, Error>> {
        repository.selectCardType(coupleCardId: coupleCardId)
    }
    
    func assignCards(startDate: String, endDate: String) -> Observable<Result<Void, Error>> {
        repository.assignCards(startDate: startDate, endDate: endDate)
    }
    
    func submitAnswers(coupleCardId: Int, cardId: Int, answers: [Answer]) -> Observable<Result<SubmitAnswerResult, Error>> {
        repository.submitAnswers(
            coupleCardId: coupleCardId, 
            cardId: cardId, 
            answers: answers
        )
    }
    
    func notiAgree() -> Observable<Bool> {
        repository.notiAgree()
    }
}
