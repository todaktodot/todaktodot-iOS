//
//  ShareLinkRepository.swift
//  todaktodot
//
//  Created by daye on 7/7/26.
//

import RxSwift

protocol ShareLinkRepository {
    func createShareLink(coupleCardId: Int) -> Observable<Result<ShareLink, Error>>
    func validateShareLink(token: String) -> Observable<Result<ShareLinkStatus, Error>>
}
