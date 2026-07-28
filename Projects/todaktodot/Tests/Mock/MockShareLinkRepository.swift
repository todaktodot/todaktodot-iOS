//
//  MockShareLinkRepository.swift
//  todaktodotTests
//
//  Created by daye on 7/28/26.
//

import RxSwift
@testable import todaktodot

final class MockShareLinkRepository: ShareLinkRepository {
    
    var createShareLinkResult: Observable<Result<ShareLink, Error>> = .just(.success(ShareLink(shareUrl: "https://todaktodot.com/share/abc", shareToken: "abc", expiredAt: nil)))
    var validateShareLinkResult: Observable<Result<ShareLinkStatus, Error>> = .just(.success(.valid(coupleCardId: 1)))
    var createShareLinkCallCount = 0
    
    func createShareLink(coupleCardId: Int) -> Observable<Result<ShareLink, Error>> {
        createShareLinkCallCount += 1
        return createShareLinkResult
    }
    
    func validateShareLink(token: String) -> Observable<Result<ShareLinkStatus, Error>> {
        validateShareLinkResult
    }
}
