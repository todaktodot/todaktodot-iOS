//
//  HistoryCardDTO.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation

struct CardHistoryResponseDTO: Decodable {
    let startDate: String
    let endDate: String
    let historyCards: [HistoryCardDTO]
}

struct HistoryCardDTO: Decodable {
    let issuedDate: String
    let mode: String
    let subject: String
    let selected: Bool
    let coupleCardId: Int
    let cardId: Int
    let cardTitle: String
    let type: String
    let user1Answered: Bool
    let user2Answered: Bool
    let questions: [HistoryQuestionDTO]
    let feedback: FeedbackDTO?
}

struct HistoryQuestionDTO: Decodable {
    let questionNo: Int
    let questionType: String
    let questionCnts: String
    let answerReqYn: String
    let options: [HistoryOptionDTO]?
}

struct HistoryOptionDTO: Decodable {
    let optionNo: Int
    let optionCnts: String
}

struct FeedbackDTO: Decodable {
    let feedbackId: Int
    let summary: String
    let matchPoints: String
    let differences: String
    let conversationStarter: String
}

extension CardHistoryResponseDTO {
    func toEntity() -> [QuestionCard] {
        return historyCards.map { card in
            QuestionCard(
                id: card.cardId,
                coupleCardId: card.coupleCardId,
                title: card.cardTitle,
                date: ISO8601DateFormatter().date(from: card.issuedDate) ?? Date(),
                mode: card.mode,
                subject: card.subject,
                type: card.type,
                questions: card.questions.map { q in
                    Question(
                        number: q.questionNo,
                        content: q.questionCnts,
                        type: q.questionType,
                        isRequired: q.answerReqYn == "Y",
                        options: q.options?.map { QuestionOption(id: $0.optionNo, text: $0.optionCnts) } ?? []
                    )
                },
                isSelected: card.selected,
                user1Answered: card.user1Answered,
                user2Answered: card.user2Answered,
                feedback: card.feedback.map { f in
                    CardFeedback(
                        id: f.feedbackId,
                        summary: f.summary,
                        score: Int(f.matchPoints.filter { $0.isNumber }) ?? 0,
                        differences: f.differences,
                        tip: f.conversationStarter
                    )
                }
            )
        }
    }
}
