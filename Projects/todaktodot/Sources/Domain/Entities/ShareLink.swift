//
//  ShareLink.swift
//  todaktodot
//
//  Created by daye on 7/7/26.
//

import Foundation

struct ShareLink {
    let shareUrl: String
    let shareToken: String
    let expiredAt: String?
}

enum ShareLinkStatus {
    case valid(coupleCardId: Int)
    case expired(message: String?)
    case forbidden(message: String?)
    case notFound(message: String?)
    case unknown(message: String?)
}
