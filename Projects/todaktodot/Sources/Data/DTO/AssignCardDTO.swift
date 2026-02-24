//
//  AssignCardDTO.swift
//  todaktodot
//
//  Created by 임대진 on 2/23/26.
//

import Foundation

struct AssignCardDTO: Decodable {
    let coupleId: Int
    let startDate: String
    let endDate: String
    let assignedCount: Int
    let skippedDateCount: Int
}

