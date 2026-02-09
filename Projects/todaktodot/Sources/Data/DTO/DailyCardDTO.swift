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
    let mode: CardMode        // String -> CardMode
    let subject: CardSubject  // String -> CardSubject
    let type: CardType?       // String -> CardType? (안전하게 Optional 처리)
    let questions: [QuestionDTO]
}

struct QuestionDTO: Decodable {
    let questionNo: Int
    let questionType: String
    let questionCnts: String  // 서버 필드명 유지
    let answerReqYn: String   // Y|N
    let options: [OptionDTO]?
}

struct OptionDTO: Decodable {
    let optionNo: Int
    let optionCnts: String
}

// MARK: - Mapping Extension
extension DailyCardResponseDTO {
    func toEntity() -> [QuestionCard] {
        return dailyCards.map { card in
            QuestionCard(
                id: card.cardId,
                coupleCardId: card.coupleCardId,
                title: card.cardTitle,
                date: {
                    // 서버 날짜 형식이 yyyy-MM-dd일 가능성이 높으므로 커스텀 포맷터 권장
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.date(from: card.issuedDate) ?? Date()
                }(),
                mode: card.mode,
                subject: card.subject, 
                type: card.type ?? .situation,
                questions: card.questions.map { q in
                    Question(
                        number: q.questionNo,
                        content: q.questionCnts,
                        type: q.questionType,
                        isRequired: q.answerReqYn == "Y",
                        options: q.options?.map {
                            QuestionOption(id: $0.optionNo, text: $0.optionCnts)
                        } ?? []
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
