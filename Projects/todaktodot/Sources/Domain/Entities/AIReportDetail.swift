//
//  AIReportDetail.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import Foundation

struct AIReportDetail: Decodable {
    let reportId: Int
    let startDt: String // "2026-02-21"
    let endDt: String
    let totalSyncRate: Int
    let economySyncRate: CGFloat
    let lifeSyncRate: CGFloat
    let loveSyncRate: CGFloat
    let dailycardAnswerRate: CGFloat
    let totalDailycardAnswerCnt: Int
    let insight: [String?]
    let similarSubjectList: [Subject]
    let differentSubjectList: [Subject]
}
