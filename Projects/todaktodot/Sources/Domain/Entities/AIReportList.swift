//
//  AIReportList.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import Foundation

struct AIReportList: Codable {
    let yearMonth: String
    let month: Int
    let week: Int
    let reportId: Int
}

extension AIReportList {
    static var mock: [AIReportList] = [
        AIReportList(yearMonth: "2026",
              month: 1,
              week: 1,
              reportId: 1),
        AIReportList(yearMonth: "2026",
              month: 1,
              week: 3,
              reportId: 3),
        AIReportList(yearMonth: "2026",
              month: 1,
              week: 4,
              reportId: 4),
        AIReportList(yearMonth: "2026",
              month: 2,
              week: 2,
              reportId: 2),
    ]
}
