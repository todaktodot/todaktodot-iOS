//
//  CardRepository.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import RxSwift

protocol CardRepository {
    func fetchWeeklyCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>>
    func fetchHistoryCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>>
    func selectCardType(coupleCardId: Int) -> Observable<Result<Void, Error>>
    func assignCards(startDate: String, endDate: String) -> Observable<Result<Void, Error>>
    func submitAnswers(coupleCardId: Int, cardId: Int, answers: [Answer]) -> Observable<Result<SubmitAnswerResult, Error>>
    func pokeDailyCard(coupleCardId: Int) -> Observable<Result<Void, Error>>
}
