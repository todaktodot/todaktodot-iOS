//
//  AIReportCreated.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import Foundation

struct AIReportCreated: Decodable {
    let reportId: Int
    let creatable: Bool
    let initialize: Bool
    
    enum CodingKeys: String, CodingKey {
        case reportId, creatable
        case initialize = "initalize"
    }
}
