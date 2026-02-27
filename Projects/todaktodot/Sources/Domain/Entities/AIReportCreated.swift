//
//  AIReportCreated.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import Foundation

struct AIReportCreated: Decodable {
    let reportId: Int
    /// 리포트 존재 여부
    let creatable: Bool
    /// 리포트 생성 여부 true 면 첫 진입
    let initialize: Bool
    
    enum CodingKeys: String, CodingKey {
        case reportId, creatable
        case initialize = "initalize"
    }
}

extension AIReportCreated {
    static var mock : Self {
        Self(reportId: 1, creatable: true, initialize: true)
    }
}
