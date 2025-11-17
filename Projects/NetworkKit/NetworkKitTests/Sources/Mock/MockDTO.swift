//
//  MockDTO.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation

struct MockDTO {
    
    struct AdviceDTO: Codable {
        let slip: AdviceSlip
    }

    struct AdviceSlip: Codable {
        let id: Int
        var content: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case content = "advice"
        }
    }
}
