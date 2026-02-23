//
//  SoloDTO.swift
//  todaktodot
//
//  Created by 임대진 on 2/23/26.
//

import Foundation

struct SoloDTO: Decodable {
    let coupleId: Int
    let coupleType: String
    let startedAt: String
    let message: String
}
