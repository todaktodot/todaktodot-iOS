//
//  VoteOption.swift
//  todaktodot
//
//  Created by 임대진 on 8/27/26.
//

import Foundation

struct VoteOption: Codable, Equatable {
    let optionId: Int // 답변 ID
    let content: String // 답변 내용
    let voteCnt: Int? // 득표 수
    let voteRate: CGFloat? // 득표 비율
    let selected: Bool // 해당 옵션을 선택했는지 여부
}

