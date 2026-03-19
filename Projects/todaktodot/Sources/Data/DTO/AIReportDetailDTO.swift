//
//  AIReportDetailDTO.swift
//  todaktodot
//
//  Created by 임대진 on 2/24/26.
//

import Foundation

struct AIReportDetailDTO: Decodable {
    let reportId: Int
    let startDt: String // "2026-02-21"
    let endDt: String
    
    let totalDailycardAnswerCnt: String
    let totalSyncRate: String
    let economySyncRate: String
    let lifeSyncRate: String
    let loveSyncRate: String
    let dailycardAnswerRate: String
    
    let insightInfo: InsightInfo
    let similarSubjectList: [Subject]
    let diffrentSubjectList: [Subject]
}

struct InsightInfo: Decodable {
    let insightId: Int
    let summary: String?
    let economyPart: String?
    let lifestylePart: String?
    let lovePart: String?
}

struct Subject: Decodable {
    let coupleCardId: Int
    let issuedDt: String
    let mode: String // "위스키모드" 등
    let subject: String // "경제관" 등
}

extension AIReportDetailDTO {
    func toDetail() -> AIReportDetail {
        AIReportDetail(reportId: reportId,
                       startDt: startDt.toKRFomatter(),
                       endDt: endDt.toKRFomatter(excepYear: true),
                       totalSyncRate: Int(totalSyncRate) ?? 0,
                       economySyncRate: CGFloat((Double(economySyncRate) ?? 0) / 100.0),
                       lifeSyncRate: CGFloat((Double(lifeSyncRate) ?? 0) / 100.0),
                       loveSyncRate: CGFloat((Double(loveSyncRate) ?? 0) / 100.0),
                       dailycardAnswerRate: CGFloat((Double(dailycardAnswerRate) ?? 0) / 100.0),
                       totalDailycardAnswerCnt: Int(totalDailycardAnswerCnt) ?? 0,
                       insight: [
                        insightInfo.summary,
                        insightInfo.economyPart,
                        insightInfo.lifestylePart,
                        insightInfo.lovePart
                       ],
                       similarSubjectList: similarSubjectList,
                       differentSubjectList: diffrentSubjectList)
    }
    static let mock = AIReportDetailDTO(
        reportId: 1,
        startDt: "2026-03-02",
        endDt: "2026-03-08",
        totalDailycardAnswerCnt: "14",
        totalSyncRate: "68",
        economySyncRate: "45",
        lifeSyncRate: "90",
        loveSyncRate: "80",
        dailycardAnswerRate: "85",
        insightInfo: InsightInfo(
            insightId: 1,
            summary: nil,
            economyPart: nil,
            lifestylePart: nil,
            lovePart: nil
        ),
        similarSubjectList: [
            Subject(coupleCardId: 202, issuedDt: "2026-02-17", mode: "커피모드", subject: "연애관")
        ],
        diffrentSubjectList: [
            Subject(coupleCardId: 243, issuedDt: "2026-02-18", mode: "위스키모드", subject: "경제관"),
            Subject(coupleCardId: 203, issuedDt: "2026-02-21", mode: "위스키모드", subject: "생활관")
        ]
    )
}
