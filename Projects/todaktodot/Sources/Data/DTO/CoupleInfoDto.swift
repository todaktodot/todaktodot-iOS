//
//  CoupleInfoDto.swift
//  todaktodot
//
//  Created by 임대진 on 2/4/26.
//

import Foundation

struct CoupleInfoDto: Codable {
    let coupleId: Int
    let userId1: Int
    let userId2: Int
    let connectedDt: String
    let firstMetDt: String
    let relationshipStage: String
}
