//
//  CardRepository.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import RxSwift

protocol CardRepository {
    func fetchWeeklyCards(startDate: String, endDate: String) -> Observable<[QuestionCard]>
    func fetchHistoryCards(startDate: String, endDate: String) -> Observable<[QuestionCard]>

    func selectCardType(coupleCardId: Int) -> Observable<Bool>
    func assignCards(startDate: String, endDate: String) -> Observable<Bool> // me랑 뭔차인ㅈㅣ...
    func submitAnswers(coupleCardId: Int, cardId: Int, answers: [AnswerInput]) -> Observable<Bool>
}
