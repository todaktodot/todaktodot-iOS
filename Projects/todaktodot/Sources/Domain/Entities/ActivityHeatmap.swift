//
//  ActivityHeatmap.swift
//  todaktodot
//
//  Created by 임대진 on 7/1/26.
//

import Foundation

struct ActivityHeatmap: Codable {
    let days: [ActivityDay]
}

struct ActivityDay: Codable {
    let date: String
    let status: Status

    enum Status: String, Codable {
        case none = "NONE"
        case meOnly = "ME_ONLY"
        case partnerOnly = "PARTNER_ONLY"
        case both = "BOTH"
    }
}
