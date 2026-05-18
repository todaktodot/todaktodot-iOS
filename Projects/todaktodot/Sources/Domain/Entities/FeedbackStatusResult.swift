//
//  FeedbackStatusResult.swift
//  todaktodot
//
//  Created by daye on 5/13/26.
//

import Foundation

enum FeedbackStatus: String, Codable {
    case notStarted = "NOT_STARTED"
    case generating = "GENERATING"
    case completed = "COMPLETED"
    case failed = "FAILED"
}

struct FeedbackStatusResult {
    let status: FeedbackStatus
    let feedback: CardFeedback?
}
