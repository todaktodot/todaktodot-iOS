//
//  HistoryCardDTO.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation

import Foundation

struct CardHistoryResponseDTO: Decodable {
    let startDate: String
    let endDate: String
    let historyCards: [HistoryCardDTO]?
}

struct HistoryCardDTO: Decodable {
    let issuedDate: String?
    let mode: CardMode?
    let subject: CardSubject?
    let selected: Bool?
    let situation: String?
    let coupleCardId: Int?
    let cardId: Int?
    let cardTitle: String?
    let type: CardType?
    let user1Answered: Bool?
    let user2Answered: Bool?
    let userId1: Int?
    let userId2: Int?
    let questions: [HistoryQuestionDTO]?
    let feedback: FeedbackDTO?
}

struct HistoryQuestionDTO: Decodable {
    let questionNo: Int?
    let questionType: String?
    let questionCnts: String?
    let answerReqYn: String?
    let options: [HistoryOptionDTO]?
    let user1Answer: String?
    let user2Answer: String?
}

struct HistoryOptionDTO: Decodable {
    let optionNo: Int?
    let optionCnts: String?
}

struct FeedbackDTO: Decodable {
    let feedbackId: Int
    let summary: String
    let matchPoints: String
    let differences: String
    let conversationStarter: String
}

// MARK: - Mapping Extension
extension CardHistoryResponseDTO {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func toEntity() -> [QuestionCard] {
        return historyCards?.map { card in
            QuestionCard(
                id: card.cardId ?? 0,
                coupleCardId: card.coupleCardId ?? 0,
                title: card.cardTitle ?? "미발행 카드",
                date: Self.dateFormatter.date(from: card.issuedDate ?? "") ?? Date(),
                mode: card.mode ?? .whiskey,
                subject: card.subject ?? .love,
                type: card.type ?? .balance,
                questions: card.questions?.map { q in
                    Question(
                        number: q.questionNo ?? -1,
                        content: q.questionCnts ?? "",
                        type: QuestionType(rawValue: q.questionType ?? "") ?? .subjective ,
                        isRequired: q.answerReqYn == "Y",
                        options: q.options?.map {
                            QuestionOption(id: $0.optionNo ?? -1, text: $0.optionCnts ?? "") // 수정됨
                        } ?? [],
                        user1Answer: q.user1Answer,
                        user2Answer: q.user2Answer
                    )
                } ?? [],
                situation: card.situation ?? "",
                isSelected: card.selected ?? false,
                user1Answered: card.user1Answered ?? false,
                user2Answered: card.user2Answered ?? false,
                userId1: card.userId1,
                userId2: card.userId2,
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
        } ?? []
    }
}
