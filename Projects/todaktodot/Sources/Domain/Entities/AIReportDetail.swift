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
    let totalSyncRate: String
    let economySyncRate: String
    let lifeSyncRate: String
    let loveSyncRate: String
    let dailycardAnswerRate: String
    let totalDailycardAnswerCnt: String
    let insightInfo: InsightInfo
    let similarSubjectList: [Subject]
    let diffrentSubjectList: [Subject]
    
    struct InsightInfo: Decodable {
        let insightId: Int
        let content: String
    }

    struct Subject: Decodable {
        let coupleCardId: Int
        let issuedDt: String
        let mode: String // "위스키모드" 등
        let subject: String // "경제관" 등
    }
}

extension AIReportDetail {
    static let mock = AIReportDetail(
        reportId: 1,
        startDt: "2026-02-16",
        endDt: "2026-02-22",
        totalSyncRate: "78",
        economySyncRate: "45",
        lifeSyncRate: "90",
        loveSyncRate: "80",
        dailycardAnswerRate: "85",
        totalDailycardAnswerCnt: "14",
        insightInfo: InsightInfo(
            insightId: 1,
            content: "이번 주 A와 B는 서로 다른 관점을 가지면서도 핵심 가치에서는 놀라울 정도로 일치하는 모습을 보였어요. 특히 연애관에서는 상당한 싱크로율을 보이며, 서로를 배려하는 마음이 답변 곳곳에 드러났어요. 경제관에서는 실용성과 낭만 사이에서 서로 다른 균형점을 찾고 있지만, 이런 차이가 오히려 서로에게 새로운 시각을 제공하고 있습니다. 생활관 부분에서 가장 많은 차이를 보였는데, 이는 각자의 생활 패턴과 우선순위가 다르기 때문으로 보여요."
        ),
        similarSubjectList: [
            Subject(coupleCardId: 101, issuedDt: "2026-02-17", mode: "커피모드", subject: "연애관"),
            Subject(coupleCardId: 102, issuedDt: "2026-02-19", mode: "디저트모드", subject: "생활관")
        ],
        diffrentSubjectList: [
            Subject(coupleCardId: 103, issuedDt: "2026-02-18", mode: "위스키모드", subject: "경제관"),
            Subject(coupleCardId: 104, issuedDt: "2026-02-21", mode: "위스키모드", subject: "생활관")
        ]
    )
}
