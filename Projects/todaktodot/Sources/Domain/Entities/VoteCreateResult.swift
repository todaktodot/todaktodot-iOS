//
//  VoteCreateResult.swift
//  todaktodot
//
//  Created by daye on 8/31/26.
//

import Foundation

/// 투표 생성 response
struct VoteCreateResult: Codable, Equatable {
    let voteId: Int // 생성된 투표 ID
}
