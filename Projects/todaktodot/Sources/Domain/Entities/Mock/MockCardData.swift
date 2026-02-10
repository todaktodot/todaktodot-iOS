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
        QuestionCard(
            id: 1,
            coupleCardId: 101,
            title: "데이트 비용 분담",
            date: Date().addingTimeInterval(-3 * 24 * 3600),
            mode: .coffee,
            subject: .economy,  
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "데이트 비용을 어떻게 분담하시나요?",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "완전히 반반"),
                        QuestionOption(id: 2, text: "번갈아가며 내기")
                    ],
                    user1Answer: nil,
                    user2Answer: nil
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: nil,
                    user2Answer: nil
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            userId1: nil,
            userId2: nil,
            feedback: nil
        ),

        QuestionCard(
            id: 2,
            coupleCardId: 102,
            title: "주말 약속 생겼을 때",
            date: Date().addingTimeInterval(-2 * 24 * 3600),
            mode: .dessert,
            subject: .lifestyle,
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "갑자기 주말에 약속이 생겼다면?",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "연인과 먼저 상의한다"),
                        QuestionOption(id: 2, text: "거절한다")
                    ],
                    user1Answer: nil,
                    user2Answer: nil
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: nil,
                    user2Answer: nil
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            userId1: nil,
            userId2: nil,
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
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "계획적으로 일정 짜기"),
                        QuestionOption(id: 2, text: "즉흥적으로 돌아다니기")
                    ],
                    user1Answer: nil,
                    user2Answer: nil
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: nil,
                    user2Answer: nil
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            userId1: nil,
            userId2: nil,
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
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "카페"),
                        QuestionOption(id: 2, text: "영화관")
                    ],
                    user1Answer: "카페",
                    user2Answer: "카페"
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: "편하게 대화할 수 있어서",
                    user2Answer: "조용하고 분위기 좋아서"
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            userId1: 1001,
            userId2: 1002,
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
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "저축/투자"),
                        QuestionOption(id: 2, text: "여행")
                    ],
                    user1Answer: "저축/투자",
                    user2Answer: "여행"
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: "미래를 위해 준비하고 싶어서",
                    user2Answer: "지금 이 순간을 즐기고 싶어서"
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            userId1: 1001,
            userId2: 1002,
            feedback: CardFeedback(
                id: 3,
                summary: "금전 가치관에서 차이가 있어요.",
                score: 68,
                differences: "한 분은 저축을, 한 분은 경험을 중시하시네요.",
                tip: "서로의 가치관을 이해하고 균형점을 찾아보세요."
            )
        ),
        QuestionCard(
            id: 14,
            coupleCardId: 204,
            title: "갈등 해결 방식",
            date: Date().addingTimeInterval(-10 * 24 * 3600),
            mode: .dessert,
            subject: .lifestyle,
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "연인과 의견이 다를 때 어떻게 하나요?",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "바로 대화로 풀기"),
                        QuestionOption(id: 2, text: "시간을 두고 생각하기")
                    ],
                    user1Answer: "바로 대화로 풀기",
                    user2Answer: "시간을 두고 생각하기"
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: "빨리 해결하는 게 좋아서",
                    user2Answer: nil
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            userId1: 1001,
            userId2: 1002,
            feedback: CardFeedback(
                id: 4,
                summary: "갈등 해결 방식이 달라요.",
                score: 72,
                differences: "한 분은 즉각적인 해결을, 한 분은 신중한 접근을 선호하시네요.",
                tip: "서로의 방식을 존중하며 중간 지점을 찾아보세요."
            )
        ),
        QuestionCard(
            id: 15,
            coupleCardId: 205,
            title: "연락 빈도",
            date: Date().addingTimeInterval(-8 * 24 * 3600),
            mode: .coffee,
            subject: .lifestyle,
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "하루에 연락은 얼마나 자주 하나요?",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "수시로 연락"),
                        QuestionOption(id: 2, text: "하루 1-2번 정도")
                    ],
                    user1Answer: "수시로 연락",
                    user2Answer: "하루 1-2번 정도"
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: nil,
                    user2Answer: "각자 시간도 필요해서"
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            userId1: 1001,
            userId2: 1002,
            feedback: CardFeedback(
                id: 5,
                summary: "연락 빈도 선호가 다르네요.",
                score: 65,
                differences: "한 분은 자주 연락하고 싶어하고, 한 분은 적당한 거리를 선호해요.",
                tip: "서로의 스타일을 이해하고 편안한 빈도를 찾아보세요."
            )
        ),
        QuestionCard(
            id: 16,
            coupleCardId: 206,
            title: "주말 계획",
            date: Date().addingTimeInterval(-6 * 24 * 3600),
            mode: .dessert,
            subject: .lifestyle,
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "주말에 뭐하고 싶나요?",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "집에서 쉬기"),
                        QuestionOption(id: 2, text: "밖에 나가기")
                    ],
                    user1Answer: "집에서 쉬기",
                    user2Answer: nil
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: "평일에 너무 피곤해서",
                    user2Answer: nil
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: false,
            userId1: 1001,
            userId2: 1002,
            feedback: nil
        ),
        QuestionCard(
            id: 17,
            coupleCardId: 207,
            title: "선물 받고 싶은 것",
            date: Date().addingTimeInterval(-4 * 24 * 3600),
            mode: .coffee,
            subject: .lifestyle,
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "어떤 선물을 받고 싶나요?",
                    type: .multipleChoice,
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "실용적인 선물"),
                        QuestionOption(id: 2, text: "감성적인 선물")
                    ],
                    user1Answer: nil,
                    user2Answer: nil
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각한 이유는 무엇인가요?",
                    type: .subjective,
                    isRequired: false,
                    options: [],
                    user1Answer: nil,
                    user2Answer: nil
                )
            ],
            isSelected: true,
            user1Answered: false,
            user2Answered: false,
            userId1: 1001,
            userId2: 1002,
            feedback: nil
        )
    ]
}
