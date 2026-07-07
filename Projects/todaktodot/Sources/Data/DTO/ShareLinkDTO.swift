//
//  ShareLinkDTO.swift
//  todaktodot
//
//  Created by daye on 7/6/26.
//

import Foundation

// MARK: - 공유 링크 생성 응답
struct ShareLinkResponse: Decodable {
    let shareUrl: String
    let shareToken: String
    let expiredAt: String?
}

// MARK: - 공유 링크 검증 응답
struct ShareLinkValidateResponse: Decodable {
    let status: String       // "VALID", "EXPIRED", "FORBIDDEN", "NOT_FOUND"
    let coupleCardId: Int?
    let message: String?
}
