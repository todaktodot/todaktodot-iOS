//
//  FeedbackStatusDTO.swift
//  todaktodot
//
//  Created by daye on 5/13/26.
//

import Foundation

struct FeedbackStatusResponseDTO: Decodable {
    let feedbackStatus: String
    let feedback: FeedbackDTO?
}

extension FeedbackStatusResponseDTO {
    func toEntity() -> FeedbackStatusResult {
        let status = FeedbackStatus(rawValue: feedbackStatus) ?? .failed
        let cardFeedback: CardFeedback? = feedback.map { f in
            let nicknames = UserdefaultKey.nicknameInfo
            let r: [(target: String, name: String)] = [
                ("유저1", nicknames?.userNickname ?? "유저1"),
                ("유저2", nicknames?.anotherUserNickname ?? "유저2")
            ]
            return CardFeedback(
                id: f.feedbackId ?? 0,
                summary: (f.summary ?? "").replacingNicknames(r),
                matchPoints: (f.matchPoints ?? "").replacingNicknames(r),
                differences: (f.differences ?? "").replacingNicknames(r),
                tip: (f.conversationStarter ?? "").replacingNicknames(r)
            )
        }
        return FeedbackStatusResult(status: status, feedback: cardFeedback)
    }
}
