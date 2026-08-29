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
    let isMine: Bool // 내가 만든 투표인지 여부
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
    
    static var dummy: VoteInfo {
        return VoteInfo(
            voteId: -1,
            nickname: "",
            category: "",
            status: "",
            title: "",
            options: [
            ],
            likeCnt: 0,
            participantCnt: 0,
            reportCnt: 0,
            remainingTime: "",
            isMine: false,
            hasVoted: false,
            hasLiked: false,
            createdAt: ""
        )
    }
}
