//
//  HistoryCardDTO.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation

import Foundation

struct CardHistoryResponseDTO: Decodable {
    let startDate: String?
    let endDate: String?
    let user1Id: Int?
    let user2Id: Int?
    let historyCards: [HistoryCardDTO]?
}

struct HistoryCardDTO: Decodable {
    let issuedDate: String?
    let mode: CardMode?
    let subject: CardSubject?
    let selected: Bool?
    let selectedByUserId: Int?
    let situation: String?
    let coupleCardId: Int?
    let cardId: Int?
    let cardTitle: String?
    let type: CardType?
    let user1Answered: Bool?
    let user2Answered: Bool?
    let questions: [HistoryQuestionDTO]?
    let feedback: FeedbackDTO?
    let pocked: Bool?
}

struct HistoryQuestionDTO: Decodable {
    let questionNo: Int?
    let questionType: String?
    let questionContent: String?
    let answerRequired: Bool?
    let options: [HistoryOptionDTO]?
    let user1Answer: String?
    let user1Emoji: String?
    let user2Answer: String?
    let user2Emoji: String?
}

struct HistoryOptionDTO: Decodable {
    let optionNo: Int?
    let optionContent: String?
}

struct FeedbackDTO: Decodable {
    let feedbackId: Int?
    let summary: String?
    let matchPoints: String?
    let differences: String?
    let conversationStarter: String?
}

// MARK: - Mapping Extension
extension CardHistoryResponseDTO {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
  
    private func nicknameReplacements(isUser1Current: Bool) -> [(target: String, name: String)] {
        let nicknames = UserdefaultKey.nicknameInfo
        let user1Name = isUser1Current ? (nicknames?.userNickname ?? "유저1") : (nicknames?.anotherUserNickname ?? "유저1")
        let user2Name = isUser1Current ? (nicknames?.anotherUserNickname ?? "유저2") : (nicknames?.userNickname ?? "유저2")
        return [("유저1", user1Name), ("유저2", user2Name)]
    }
    
    func toEntity() -> [QuestionCard] {
        let currentUserId = UserdefaultKey.userId
        let isUser1Current = currentUserId == self.user1Id
        
        return historyCards?.map { card in
            let shouldSwap = !isUser1Current
            
            return QuestionCard(
                id: card.cardId ?? 0,
                coupleCardId: card.coupleCardId ?? 0,
                title: card.cardTitle ?? "미발행 카드",
                date: Self.dateFormatter.date(from: card.issuedDate ?? "") ?? Date(),
                mode: card.mode ?? .whiskey,
                subject: card.subject ?? .love,
                type: card.type ?? .none,
                questions: card.questions?.map { q in
                    Question(
                        number: q.questionNo ?? -1,
                        content: q.questionContent ?? "",
                        type: QuestionType(rawValue: q.questionType ?? "") ?? .subjective ,
                        isRequired: q.answerRequired ?? false,
                        options: q.options?.map {
                            QuestionOption(id: $0.optionNo ?? -1, text: $0.optionContent ?? "")
                        } ?? [],
                        user1Answer: shouldSwap ? q.user2Answer : q.user1Answer,
                        user1Emoji: EmojiType(rawValue: (shouldSwap ? q.user2Emoji : q.user1Emoji) ?? ""),
                        user2Answer: shouldSwap ? q.user1Answer : q.user2Answer,
                        user2Emoji: EmojiType(rawValue: (shouldSwap ? q.user1Emoji : q.user2Emoji) ?? "")
                    )
                } ?? [],
                situation: card.situation ?? "",
                isSelected: card.selected ?? false,
                selectedByUserId: card.selectedByUserId,
                user1Answered: shouldSwap ? (card.user2Answered ?? false) : (card.user1Answered ?? false),
                user2Answered: shouldSwap ? (card.user1Answered ?? false) : (card.user2Answered ?? false),
                userId1: shouldSwap ? self.user2Id : self.user1Id,
                userId2: shouldSwap ? self.user1Id : self.user2Id,
                feedback: card.feedback.map { f in
                    let r = nicknameReplacements(isUser1Current: isUser1Current)
                    return CardFeedback(
                        id: f.feedbackId ?? 0,
                        summary: (f.summary ?? "").replacingNicknames(r),
                        matchPoints: (f.matchPoints ?? "").replacingNicknames(r),
                        differences: (f.differences ?? "").replacingNicknames(r),
                        tip: (f.conversationStarter ?? "").replacingNicknames(r)
                    )
                },
                pocked: card.pocked
            )
        } ?? []
    }
}
