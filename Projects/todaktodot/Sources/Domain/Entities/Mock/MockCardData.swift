//
//  MockCardData.swift
//  todaktodot
//
//  Created by daye on 2/9/26.
//

import Foundation

struct MockCardData {
    
    // MARK: - Daily Cards (답변 안 한 카드들)
    static let dailyCards: [QuestionCard] = [
        // 3일 전 - 밸런스게임
        QuestionCard(
            id: 1,
            coupleCardId: 101,
            title: "데이트 비용 분담",
            date: Date().addingTimeInterval(-3 * 24 * 3600),
            mode: .coffee,       // 깔끔-
            subject: .economy,    // 깔끔-
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "데이트 비용을 어떻게 분담하시나요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "완전히 반반"),
                        QuestionOption(id: 2, text: "번갈아가며 내기")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        ),
        // 3일 전 - 상황극
        QuestionCard(
            id: 2,
            coupleCardId: 102,
            title: "주말 약속 생겼을 때",
            date: Date().addingTimeInterval(-3 * 24 * 3600),
            mode: .dessert,
            subject: .lifestyle,
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "갑자기 주말에 약속이 생겼다면?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "연인과 먼저 상의한다"),
                        QuestionOption(id: 2, text: "거절한다")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        ),
        // 오늘 - 밸런스게임
        QuestionCard(
            id: 7,
            coupleCardId: 107,
            title: "여행 스타일",
            date: Date(),
            mode: .coffee,
            subject: .lifestyle,
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "여행 갈 때 선호하는 스타일은?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "계획적으로 일정 짜기"),
                        QuestionOption(id: 2, text: "즉흥적으로 돌아다니기")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        )
    ]

    // MARK: - History Cards (답변 완료된 카드)
    static let historyCards: [QuestionCard] = [
        QuestionCard(
            id: 11,
            coupleCardId: 201,
            title: "첫 데이트 장소",
            date: Date().addingTimeInterval(-14 * 24 * 3600),
            mode: .coffee,
            subject: .lifestyle,
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "첫 데이트로 어디가 좋을까요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "카페"),
                        QuestionOption(id: 2, text: "영화관")
                    ]
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            feedback: CardFeedback(
                id: 1,
                summary: "두 분 모두 편안한 분위기를 선호하시네요!",
                score: 85,
                differences: "데이트 스타일은 비슷하지만, 활동성에서 약간의 차이가 있어요.",
                tip: "서로의 페이스를 존중하며 다양한 데이트를 시도해보세요."
            )
        ),
        QuestionCard(
            id: 13,
            coupleCardId: 203,
            title: "금전 가치관",
            date: Date().addingTimeInterval(-12 * 24 * 3600),
            mode: .whiskey,
            subject: .economy,
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "여유 자금이 생긴다면?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "저축/투자"),
                        QuestionOption(id: 2, text: "여행")
                    ]
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            feedback: CardFeedback(
                id: 3,
                summary: "금전 가치관에서 차이가 있어요.",
                score: 68,
                differences: "한 분은 저축을, 한 분은 경험을 중시하시네요.",
                tip: "서로의 가치관을 이해하고 균형점을 찾아보세요."
            )
        )
    ]
}
