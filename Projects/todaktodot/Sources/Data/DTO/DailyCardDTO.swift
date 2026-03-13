//
//  DailyCardDTO.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation

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
    let situation: String?
    let mode: CardMode
    let subject: CardSubject
    let type: CardType
    let questions: [QuestionDTO]
}

struct QuestionDTO: Decodable {
    let questionNo: Int
    let questionType: QuestionType
    let questionContent: String
    let answerRequired: Bool
    let options: [OptionDTO]?
    
    enum CodingKeys: String, CodingKey {
        case questionNo
        case questionType
        case questionContent
        case answerRequired
        case options
    }
}

struct OptionDTO: Decodable {
    let optionNo: Int
    let optionContent: String
    
    enum CodingKeys: String, CodingKey {
        case optionNo
        case optionContent
    }
}

extension DailyCardResponseDTO {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func toEntity() -> [QuestionCard] {
        return dailyCards.map { card in
            QuestionCard(
                id: card.cardId,
                coupleCardId: card.coupleCardId,
                title: card.cardTitle,
                date: Self.dateFormatter.date(from: card.issuedDate) ?? Date(),
                mode: card.mode,
                subject: card.subject, 
                type: card.type,
                questions: card.questions.map { q in
                    Question(
                        number: q.questionNo,
                        content: q.questionContent,
                        type: q.questionType,
                        isRequired: q.answerRequired,
                        options: q.options?.map {
                            QuestionOption(id: $0.optionNo, text: $0.optionContent)
                        } ?? [],
                        user1Answer: nil,
                        user2Answer: nil
                    )
                },
                situation: card.situation ?? "",
                isSelected: false,
                user1Answered: false,
                user2Answered: false,
                userId1: nil,
                userId2: nil,
                feedback: nil,
                pocked: nil
            )
        }
    }
}
