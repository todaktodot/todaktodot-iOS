//
//  MockCardData.swift
//  todaktodot
//
//  Created by daye on 2/9/26.
//

import Foundation

struct MockCardData {
    
    // MARK: - Daily Cards (답변 안 한 카드들 - 하루에 2개씩)
    static let dailyCards: [QuestionCard] = [
        // 3일 전 - 밸런스게임
        QuestionCard(
            id: 1,
            coupleCardId: 101,
            title: "데이트 비용 분담",
            date: Date().addingTimeInterval(-3 * 24 * 3600),
            mode: "커피",
            subject: "경제관",
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "데이트 비용을 어떻게 분담하시나요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "완전히 반반"),
                        QuestionOption(id: 2, text: "번갈아가며 내기"),
                        QuestionOption(id: 3, text: "소득 비율대로"),
                        QuestionOption(id: 4, text: "한 사람이 주로 부담")
                    ]
                ),
                Question(
                    number: 2,
                    content: "그렇게 생각하는 이유를 자유롭게 적어주세요.",
                    type: "주관식",
                    isRequired: false,
                    options: []
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
            mode: "디저트",
            subject: "생활관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "갑자기 주말에 약속이 생겼다면?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "연인과 먼저 상의한다"),
                        QuestionOption(id: 2, text: "바로 수락하고 나중에 말한다"),
                        QuestionOption(id: 3, text: "거절한다"),
                        QuestionOption(id: 4, text: "상황에 따라 다르다")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        ),
        // 2일 전 - 밸런스게임
        QuestionCard(
            id: 3,
            coupleCardId: 103,
            title: "결혼 후 주거 형태",
            date: Date().addingTimeInterval(-2 * 24 * 3600),
            mode: "위스키",
            subject: "연애관",
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "결혼 후 어디서 살고 싶으신가요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "신혼집 (전세/월세)"),
                        QuestionOption(id: 2, text: "부모님 근처"),
                        QuestionOption(id: 3, text: "직장 근처"),
                        QuestionOption(id: 4, text: "아직 생각 안 해봤다")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        ),
        // 2일 전 - 상황극
        QuestionCard(
            id: 4,
            coupleCardId: 104,
            title: "갈등 상황 대처법",
            date: Date().addingTimeInterval(-2 * 24 * 3600),
            mode: "커피",
            subject: "연애관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "연인과 다퉜을 때 어떻게 하시나요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "바로 대화로 풀려고 한다"),
                        QuestionOption(id: 2, text: "시간을 두고 생각한다"),
                        QuestionOption(id: 3, text: "먼저 사과한다"),
                        QuestionOption(id: 4, text: "상대가 먼저 오길 기다린다")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        ),
        // 1일 전 - 밸런스게임
        QuestionCard(
            id: 5,
            coupleCardId: 105,
            title: "미래 우선순위",
            date: Date().addingTimeInterval(-1 * 24 * 3600),
            mode: "위스키",
            subject: "경제관",
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "5년 후 가장 중요한 것은?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "경제적 안정"),
                        QuestionOption(id: 2, text: "커리어 성장"),
                        QuestionOption(id: 3, text: "가족과의 시간"),
                        QuestionOption(id: 4, text: "개인적 성장")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        ),
        // 1일 전 - 상황극
        QuestionCard(
            id: 6,
            coupleCardId: 106,
            title: "이상적인 주말",
            date: Date().addingTimeInterval(-1 * 24 * 3600),
            mode: "디저트",
            subject: "생활관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "이상적인 주말 아침은?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "늦잠 자기"),
                        QuestionOption(id: 2, text: "일찍 일어나 운동"),
                        QuestionOption(id: 3, text: "브런치 먹으러 가기"),
                        QuestionOption(id: 4, text: "집에서 여유롭게")
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
            mode: "커피",
            subject: "생활관",
            type: .balance,
            questions: [
                Question(
                    number: 1,
                    content: "여행 갈 때 선호하는 스타일은?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "계획적으로 일정 짜기"),
                        QuestionOption(id: 2, text: "즉흥적으로 돌아다니기"),
                        QuestionOption(id: 3, text: "휴식 위주로"),
                        QuestionOption(id: 4, text: "액티비티 위주로")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        ),
        // 오늘 - 상황극
        QuestionCard(
            id: 8,
            coupleCardId: 108,
            title: "선물 받았을 때",
            date: Date(),
            mode: "디저트",
            subject: "연애관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "마음에 안 드는 선물을 받았다면?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "솔직하게 말한다"),
                        QuestionOption(id: 2, text: "좋은 척 한다"),
                        QuestionOption(id: 3, text: "나중에 슬쩍 말한다"),
                        QuestionOption(id: 4, text: "마음만 받는다고 한다")
                    ]
                )
            ],
            isSelected: false,
            user1Answered: false,
            user2Answered: false,
            feedback: nil
        )
    ]

    
    // MARK: - History Cards (히스토리 카드 - 답변 완료된 카드)
    static let historyCards: [QuestionCard] = [
        QuestionCard(
            id: 11,
            coupleCardId: 201,
            title: "첫 데이트 장소",
            date: Date().addingTimeInterval(-14 * 24 * 3600), // 2주 전
            mode: "디저트",
            subject: "연애관",
            type: .situation ,
            questions: [
                Question(
                    number: 1,
                    content: "첫 데이트로 어디가 좋을까요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "카페"),
                        QuestionOption(id: 2, text: "영화관"),
                        QuestionOption(id: 3, text: "공원 산책"),
                        QuestionOption(id: 4, text: "맛집 투어")
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
            id: 12,
            coupleCardId: 202,
            title: "연락 빈도",
            date: Date().addingTimeInterval(-13 * 24 * 3600),
            mode: "커피",
            subject: "연애관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "하루에 몇 번 정도 연락하는 게 적당할까요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "수시로"),
                        QuestionOption(id: 2, text: "하루 3-5번"),
                        QuestionOption(id: 3, text: "하루 1-2번"),
                        QuestionOption(id: 4, text: "필요할 때만")
                    ]
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            feedback: CardFeedback(
                id: 2,
                summary: "연락 스타일이 잘 맞는 커플이에요!",
                score: 92,
                differences: "큰 차이 없이 비슷한 연락 빈도를 선호하시네요.",
                tip: "현재 패턴을 유지하되, 바쁠 때는 미리 말해주세요."
            )
        ),
        QuestionCard(
            id: 13,
            coupleCardId: 203,
            title: "금전 가치관",
            date: Date().addingTimeInterval(-12 * 24 * 3600),
            mode: "위스키",
            subject: "경제관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "여유 자금이 생긴다면?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "저축/투자"),
                        QuestionOption(id: 2, text: "여행"),
                        QuestionOption(id: 3, text: "자기계발"),
                        QuestionOption(id: 4, text: "취미생활")
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
        ),
        QuestionCard(
            id: 14,
            coupleCardId: 204,
            title: "가족 행사 참여",
            date: Date().addingTimeInterval(-11 * 24 * 3600),
            mode: "커피",
            subject: "생활관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "상대방 가족 행사에 얼마나 참여하고 싶으신가요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "모든 행사 참여"),
                        QuestionOption(id: 2, text: "중요한 행사만"),
                        QuestionOption(id: 3, text: "가끔"),
                        QuestionOption(id: 4, text: "부담스럽다")
                    ]
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            feedback: CardFeedback(
                id: 4,
                summary: "가족에 대한 생각이 비슷해요!",
                score: 88,
                differences: "적절한 거리감을 유지하는 것에 동의하시네요.",
                tip: "서로의 가족을 존중하며 편안한 관계를 만들어가세요."
            )
        ),
        QuestionCard(
            id: 15,
            coupleCardId: 205,
            title: "미래 계획",
            date: Date().addingTimeInterval(-10 * 24 * 3600),
            mode: "위스키",
            subject: "연애관",
            type: .situation,
            questions: [
                Question(
                    number: 1,
                    content: "결혼은 언제쯤 생각하시나요?",
                    type: "객관식",
                    isRequired: true,
                    options: [
                        QuestionOption(id: 1, text: "1년 이내"),
                        QuestionOption(id: 2, text: "2-3년 후"),
                        QuestionOption(id: 3, text: "3년 이상"),
                        QuestionOption(id: 4, text: "아직 모르겠다")
                    ]
                )
            ],
            isSelected: true,
            user1Answered: true,
            user2Answered: true,
            feedback: CardFeedback(
                id: 5,
                summary: "미래에 대한 생각이 잘 맞아요!",
                score: 90,
                differences: "비슷한 타임라인을 생각하고 계시네요.",
                tip: "구체적인 계획을 함께 세워보는 시간을 가져보세요."
            )
        )
    ]
}
