//
//  MockEndpoint.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation

internal import NetworkKit

enum MockEndpoint {
    
    static func getAdviceSlip() -> Endpoint<MockDTO.AdviceDTO> {
        return Endpoint(
            baseURL: .adviceslipAPI,
            path: "/advice",
            method: .get
        )
    }
}
