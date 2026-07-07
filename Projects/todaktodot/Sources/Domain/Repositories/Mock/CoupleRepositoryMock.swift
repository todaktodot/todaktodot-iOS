//
//  CoupleRepositoryMock.swift
//  todaktodot
//
//  Created by 임대진 on 7/1/26.
//

import RxSwift
import NetworkKit
import Alamofire
import Foundation

final class CoupleRepositoryMock: CoupleRepository {
    
    func issueCode() -> RxSwift.Observable<CoupleCode> {
        return .just(CoupleCode(linkCode: "", expiredDt: ""))
    }

    func connectCouple(code: String) -> RxSwift.Observable<Bool> {
        return .just(true)
    }

    func updateNickname(nickname: String) -> RxSwift.Observable<String> {
        return .just("nickname")
    }

    func updateCoupleInfo(date: String, stage: String) -> RxSwift.Observable<CoupleInfo> {
        return .just(CoupleInfo(firstMetDate: "", sinceMetDate: "", stage: ""))
    }

    func setTerms(infoAgree: Bool?, marketingAgree: Bool?, advertiesmentAgree: Bool?) -> RxSwift.Observable<Bool> {
        return .just(true)
    }

    func soloStart() -> RxSwift.Observable<Bool> {
        return .just(true)
    }

    func assignCards(startDate: String, endDate: String) -> RxSwift.Observable<Bool> {
        return .just(true)
    }

    func setOnboarding(info: OnboardingInfo) -> RxSwift.Observable<String> {
        return .just("nickname")
    }
}
