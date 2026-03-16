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
    let user2Answer: String?
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
    
    private func replaceNicknames(in text: String?, isUser1Current: Bool) -> String? {
        guard let text else { return nil }
        let nicknames = UserdefaultKey.nicknameInfo
        let user1Name = isUser1Current ? (nicknames?.userNickname ?? "유저1") : (nicknames?.anotherUserNickname ?? "유저1")
        let user2Name = isUser1Current ? (nicknames?.anotherUserNickname ?? "유저2") : (nicknames?.userNickname ?? "유저2")
        
        let josaReplace = [
            ("라서", "이라서"), ("라고", "이라고"), ("라면", "이라면"),
            ("라는", "이라는"), ("이니까", "이니까"), ("니까", "이니까"),
            ("이랑", "이랑"), ("이나", "이나"),
            ("는", "은"), ("가", "이"), ("를", "을"), ("와", "과"),
            ("야", "아"), ("로", "으로"), ("나", "이나"), ("랑", "이랑"),
            ("란", "이란"), ("네", "이네"), ("다", "이다"), ("며", "이며")
        ]
        
        var result = text
        for (user, name) in [("유저1", user1Name), ("유저2", user2Name)] {
            for (wrong, correct) in josaReplace {
                result = result.replacingOccurrences(of: "\(user)\(wrong)", with: "\(name)님\(correct)")
            }
            result = result.replacingOccurrences(of: user, with: "\(name)님")
        }
        return result
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
                        user2Answer: shouldSwap ? q.user1Answer : q.user2Answer
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
                    CardFeedback(
                        id: f.feedbackId ?? 0,
                        summary: replaceNicknames(in: f.summary, isUser1Current: isUser1Current) ?? "",
                        matchPoints: replaceNicknames(in: f.matchPoints, isUser1Current: isUser1Current) ?? "",
                        differences: replaceNicknames(in: f.differences, isUser1Current: isUser1Current) ?? "",
                        tip: replaceNicknames(in: f.conversationStarter, isUser1Current: isUser1Current) ?? ""
                    )
                },
                pocked: card.pocked
            )
        } ?? []
    }
}
