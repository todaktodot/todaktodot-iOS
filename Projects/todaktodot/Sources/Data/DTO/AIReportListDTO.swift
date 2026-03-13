//
//  AIReportListDTO.swift
//  todaktodot
//
//  Created by 임대진 on 2/27/26.
//

import Foundation

struct AIReportListDTO: Decodable {
    let yearMonth: String
    let month: String
    let week: String
    let reportId: Int
}

extension AIReportListDTO {
    func toAIReportList() -> AIReportList {
        AIReportList(yearMonth: yearMonth, month: Int(month) ?? 1, week: Int(week) ?? 1, reportId: reportId)
    }
}
