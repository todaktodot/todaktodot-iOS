//
//  DailyCardDTO.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import UIKit


struct DailyCardResponseDTO: Decodable {
    let startDate: String
    let endDate: String
    let dailyCards: [DailyCardDTO]
}

struct DailyCardDTO: Decodable {
    let coupleCardId: Int
    let cardId: Int
    let issuedDate: String
    let cardTitle: String
    let mode: String
    let subject: String
    let type: String //TODO: 타입 물어보기
    let questions: [QuestionDTO]
}

struct QuestionDTO: Decodable {
    let questionNo: Int
    let questionType: String
    let questionCnts: String
    let answerReqYn: String // Y|N
    let options: [OptionDTO]?
}

struct OptionDTO: Decodable {
    let optionNo: Int
    let optionCnts: String
}


extension DailyCardResponseDTO {
    func toEntity() -> [QuestionCard] {
        return dailyCards.map { card in
            QuestionCard(
                id: card.cardId,
                coupleCardId: card.coupleCardId,
                title: card.cardTitle,
                date: ISO8601DateFormatter().date(from: card.issuedDate) ?? Date(),
                mode: card.mode,
                subject: card.subject,
                type: CardType(rawValue: card.type) ?? .situation,
                questions: card.questions.map { q in
                    Question(
                        number: q.questionNo,
                        content: q.questionCnts,
                        type: q.questionType,
                        isRequired: q.answerReqYn == "Y",
                        options: q.options?.map { QuestionOption(id: $0.optionNo, text: $0.optionCnts) } ?? []
                    )
                },
                isSelected: false,
                user1Answered: false,
                user2Answered: false,
                feedback: nil
            )
        }
    }
}
