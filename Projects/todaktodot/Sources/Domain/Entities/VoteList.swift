//
//  VoteList.swift
//  todaktodot
//
//  Created by 임대진 on 8/25/26.
//

import Foundation

struct VoteList: Decodable, Sequence, Equatable {
    let data: [VoteInfo]?
    let createVoteCnt: Int?
    let nextCursor: String?
    let hasNext: Bool
    let isSuspended: Bool?
    
    func makeIterator() -> [VoteInfo].Iterator {
        (data ?? []).makeIterator()
    }
}
