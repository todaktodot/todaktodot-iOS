//
//  VoteInfo.swift
//  todaktodot
//
//  Created by 임대진 on 8/12/26.
//


import Foundation

struct VoteInfo: Codable, Equatable {
    let voteId: Int // 투표 ID
    let nickname: String // 투표를 만든 사람의 닉네임
    private let category: String // 카테고리명
    let status: String // 투표 상태
    let title: String // 투표 주제
    let options: [VoteOption] // 답변 목록
    let likeCnt: Int // 좋아요 수
    let participantCnt: Int // 참여자 수
    let reportCnt: Int // 신고 누적 수
    private let remainingTime: String // 남은 시간
    let mine: Bool // 내가 만든 투표인지 여부
    let hasVoted: Bool // 내가 투표했는지 여부
    let hasLiked: Bool // 내가 좋아요를 눌렀는지 여부
    let createdAt: String // 투표 등록 시간

    var categoryName: String {
        switch category {
        case "LOVE": "연애관"
        case "LIFESYCLE": "생활관"
        case "ECONOMY": "경제관"
        default: category
        }
    }
    
    var time: String {
        remainingTime == "마감" ? "마감" : "\(remainingTime)시간 남음"
    }
    
    static let dummy = VoteInfo(
        voteId: 4,
        nickname: "닉네임",
        category: "취향",
        status: "CLOSED",
        title: "여름 휴가로 가장 가고 싶은 곳은?",
        options: [
            VoteOption(
                optionId: 7,
                content: "바다",
                voteCnt: 92,
                voteRate: 0.46,
                selected: false
            ),
            VoteOption(
                optionId: 8,
                content: "산",
                voteCnt: 38,
                voteRate: 0.19,
                selected: false
            ),
            VoteOption(
                optionId: 9,
                content: "해외여행",
                voteCnt: 70,
                voteRate: 0.35,
                selected: false
            )
        ],
        likeCnt: 27,
        participantCnt: 200,
        reportCnt: 0,
        remainingTime: "투표 종료",
        mine: false,
        hasVoted: false,
        hasLiked: true,
        createdAt: "2026-08-10T09:00:00"
    )
    
    static let dummyList: [VoteInfo] = [
        VoteInfo(
            voteId: 1,
            nickname: "닉네임",
            category: "연애관",
            status: "ACTIVE",
            title: "애인이 이성 동창 모임에 가서 새벽 1시까지 술을 마신다면?",
            options: [
                VoteOption(
                    optionId: 1,
                    content: "쿨하게 잘 다녀오라고 한다",
                    voteCnt: 88,
                    voteRate: 0.8,
                    selected: true
                ),
                VoteOption(
                    optionId: 2,
                    content: "12시 전에 들어오라고 한다",
                    voteCnt: 22,
                    voteRate: 0.2,
                    selected: false
                )
            ],
            likeCnt: 42,
            participantCnt: 110,
            reportCnt: 0,
            remainingTime: "22시간 남음",
            mine: true,
            hasVoted: true,
            hasLiked: true,
            createdAt: "2026-08-14T10:00:00"
        ),
        
        VoteInfo(
            voteId: 2,
            nickname: "닉네임",
            category: "음식",
            status: "ACTIVE",
            title: "평생 하나의 음식만 먹어야 한다면?",
            options: [
                VoteOption(
                    optionId: 3,
                    content: "치킨",
                    voteCnt: 145,
                    voteRate: 0.65,
                    selected: false
                ),
                VoteOption(
                    optionId: 4,
                    content: "피자",
                    voteCnt: 78,
                    voteRate: 0.35,
                    selected: false
                )
            ],
            likeCnt: 31,
            participantCnt: 223,
            reportCnt: 0,
            remainingTime: "1일 남음",
            mine: false,
            hasVoted: false,
            hasLiked: false,
            createdAt: "2026-08-13T18:30:00"
        ),
        
        VoteInfo(
            voteId: 3,
            nickname: "닉네임",
            category: "일상",
            status: "ACTIVE",
            title: "주말에 집에만 있기 vs 밖에 나가기",
            options: [
                VoteOption(
                    optionId: 5,
                    content: "집에서 푹 쉬기",
                    voteCnt: 54,
                    voteRate: 0.42,
                    selected: true
                ),
                VoteOption(
                    optionId: 6,
                    content: "밖에 나가서 놀기",
                    voteCnt: 74,
                    voteRate: 0.58,
                    selected: false
                )
            ],
            likeCnt: 18,
            participantCnt: 128,
            reportCnt: 1,
            remainingTime: "3일 남음",
            mine: false,
            hasVoted: true,
            hasLiked: false,
            createdAt: "2026-08-12T14:20:00"
        ),
        
        VoteInfo(
            voteId: 4,
            nickname: "닉네임",
            category: "취향",
            status: "CLOSED",
            title: "여름 휴가로 가장 가고 싶은 곳은?",
            options: [
                VoteOption(
                    optionId: 7,
                    content: "바다",
                    voteCnt: 92,
                    voteRate: 0.46,
                    selected: false
                ),
                VoteOption(
                    optionId: 8,
                    content: "산",
                    voteCnt: 38,
                    voteRate: 0.19,
                    selected: false
                ),
                VoteOption(
                    optionId: 9,
                    content: "해외여행",
                    voteCnt: 70,
                    voteRate: 0.35,
                    selected: false
                )
            ],
            likeCnt: 27,
            participantCnt: 200,
            reportCnt: 0,
            remainingTime: "투표 종료",
            mine: false,
            hasVoted: false,
            hasLiked: true,
            createdAt: "2026-08-10T09:00:00"
        )
    ]
}
