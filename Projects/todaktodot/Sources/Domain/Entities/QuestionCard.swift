//
//  HistoryCard.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import UIKit

struct QuestionCard: Codable {
    let id: Int
    let coupleCardId: Int
    let title: String
    let date: Date
    let mode: CardMode
    let subject: CardSubject
    let type: CardType
    let questions: [Question]
    let situation: String
    
    // + 히스토리
    let isSelected: Bool
    let selectedByUserId: Int?
    let user1Answered: Bool
    let user2Answered: Bool
    let userId1: Int?
    let userId2: Int?
    let feedback: CardFeedback?
    let pocked: Bool?

    var isBothAnswered: Bool {
        user1Answered && user2Answered
    }
    
    var hasFeedback: Bool {
        feedback != nil
    }
}

struct Question: Codable {
    let number: Int
    let content: String
    let type: QuestionType
    let isRequired: Bool
    let options: [QuestionOption]
    let user1Answer: String?
    let user1Emoji: EmojiType?
    let user2Answer: String?
    let user2Emoji: EmojiType?
}

struct QuestionOption: Codable {
    let id: Int
    let text: String
}

struct CardFeedback: Codable {
    let id: Int
    let summary: String
    let matchPoints: String
    let differences: String
    let tip: String
}
