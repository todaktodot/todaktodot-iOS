//
//  VoteRequest.swift
//  todaktodot
//
//  Created by daye on 8/31/26.
//

import Foundation

/// 투표 생성/수정 시 답변 옵션 요청 모델
struct VoteOptionRequest: Codable, Equatable {
    let content: String // 답변 내용
    let order: Int       // 답변 순서
}

/// 투표 생성 요청 모델
struct VoteCreateRequest: Equatable {
    let category: CardSubject   // 카테고리
    let title: String           // 투표 주제
    let options: [VoteOptionRequest] // 답변 목록
}

/// 투표 수정 요청 모델
struct VoteUpdateRequest: Equatable {
    let voteId: Int             // 수정할 투표 ID
    let category: CardSubject   // 카테고리
    let title: String           // 투표 주제
    let options: [VoteOptionRequest] // 답변 목록
}
