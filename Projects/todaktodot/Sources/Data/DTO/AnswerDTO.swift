//
//  AnswerDTO.swift
//  todaktodot
//
//  Created by daye on 2/9/26.
//

import Foundation

struct SubmitAnswerRequestDTO: Encodable {
    let coupleCardId: Int
    let cardId: Int
    let answers: [AnswerDTO]
}

struct AnswerDTO: Encodable {
    let questionNo: Int
    let answerContent: String
}

struct SubmitAnswerResponseDTO: Decodable {
    let coupleCardId: Int
    let cardId: Int
    let userId: Int
    let savedCount: Int
    let savedAnswers: [SavedAnswerDTO]
    let savedAt: String
}

struct SavedAnswerDTO: Decodable {
    let answerId: Int
    let questionNo: Int
    let answerContent: String
}

extension SubmitAnswerResponseDTO {
    func toEntity() -> SubmitAnswerResult {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return SubmitAnswerResult(
            coupleCardId: coupleCardId,
            cardId: cardId,
            userId: userId,
            savedCount: savedCount,
            savedAt: dateFormatter.date(from: savedAt) ?? Date()
        )
    }
}

