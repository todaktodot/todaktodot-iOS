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

extension CoupleInfoDto {
    func toCoupleInfo() -> CoupleInfo {
        CoupleInfo(
            firstMetDate: firstMetDt,
            sinceMetDate: durationFrom(firstMetDt),
            stage: CoupleStage(rawValue: relationshipStage)?.title ?? ""
            )
    }
    
    func durationFrom(_ dateString: String) -> String { // TODO: 서버 필드값 바꿔주시면 지우기
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")

        guard let startDate = formatter.date(from: dateString) else {
            return ""
        }

        let calendar = Calendar.current
        let today = Date()

        let components = calendar.dateComponents([.year, .month, .day],
                                                 from: startDate,
                                                 to: today)

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        var parts: [String] = []
        
        if years > 0 { parts.append("\(years)년") }
        if months > 0 { parts.append("\(months)월") }
        if days > 0 { parts.append("\(days)일") }
        
        if parts.isEmpty {
            return "0일"
        }

        return parts.joined(separator: " ")
    }
}
