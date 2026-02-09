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
    let mode: CardMode        // String -> CardMode로 변경
    let subject: CardSubject  // String -> CardSubject로 변경
    let selected: Bool
    
    let coupleCardId: Int?
    let cardId: Int?
    let cardTitle: String?
    let type: CardType?       // String -> CardType?으로 변경 (null 대응)
    let user1Answered: Bool?
    let user2Answered: Bool?
    let questions: [HistoryQuestionDTO]?
    let feedback: FeedbackDTO?
}

struct HistoryQuestionDTO: Decodable {
    let questionNo: Int
    let questionType: String
    let questionContent: String?
    let answerRequired: Bool?
    let options: [HistoryOptionDTO]?
}

struct HistoryOptionDTO: Decodable {
    let optionNo: Int
    let optionContent: String
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
    func toEntity() -> [QuestionCard] {
        return historyCards.map { card in
            QuestionCard(
                id: card.cardId ?? 0,
                coupleCardId: card.coupleCardId ?? 0,
                title: card.cardTitle ?? "미발행 카드",
                date: {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.date(from: card.issuedDate) ?? Date()
                }(),
                // Enum으로 이미 파싱되었으므로 rawValue를 쓸 필요가 없음
                mode: card.mode,
                subject: card.subject,
                // Optional인 type만 기본값 처리
                type: card.type ?? .balance,
                questions: card.questions?.map { q in
                    Question(
                        number: q.questionNo,
                        content: q.questionContent ?? "",
                        type: q.questionType,
                        isRequired: q.answerRequired ?? false,
                        options: q.options?.map {
                            QuestionOption(id: $0.optionNo, text: $0.optionContent)
                        } ?? []
                    )
                } ?? [],
                isSelected: card.selected,
                user1Answered: card.user1Answered ?? false,
                user2Answered: card.user2Answered ?? false,
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
