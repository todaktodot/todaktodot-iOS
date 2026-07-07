//
//  ShareLinkUseCase.swift
//  todaktodot
//
//  Created by daye on 7/7/26.
//

import RxSwift

final class ShareLinkUseCase {
    private let repository: ShareLinkRepository

    init(repository: ShareLinkRepository) {
        self.repository = repository
    }

    func createShareLink(coupleCardId: Int) -> Observable<Result<ShareLink, Error>> {
        repository.createShareLink(coupleCardId: coupleCardId)
    }

    func validateShareLink(token: String) -> Observable<Result<ShareLinkStatus, Error>> {
        repository.validateShareLink(token: token)
    }
}
