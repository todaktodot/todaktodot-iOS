//
//  HistoryCard.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import UIKit

struct QuestionCard {
    let id: Int
    let coupleCardId: Int
    let title: String
    let date: Date
    let mode: String
    let subject: String
    let type: String
    let questions: [Question]
    
    // + 히스토리
    let isSelected: Bool
    let user1Answered: Bool
    let user2Answered: Bool
    let feedback: CardFeedback?

    var isBothAnswered: Bool {
        user1Answered && user2Answered
    }
    
    var hasFeedback: Bool {
        feedback != nil
    }
}

struct Question {
    let number: Int
    let content: String
    let type: String
    let isRequired: Bool
    let options: [QuestionOption]
}

struct QuestionOption {
    let id: Int
    let text: String
}

struct CardFeedback {
    let id: Int
    let summary: String
    let score: Int
    let differences: String
    let tip: String
}
