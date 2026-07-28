//
//  MockCoupleRepository.swift
//  todaktodotTests
//
//  Created by daye on 7/28/26.
//

import RxSwift
@testable import todaktodot

final class MockCoupleRepository: CoupleRepository {
    
    var issueCodeResult: Observable<CoupleCode> = .just(CoupleCode(linkCode: "ABC123", expiredDt: ""))
    var connectCoupleResult: Observable<Bool> = .just(true)
    var updateNicknameResult: Observable<String> = .just("닉네임")
    var updateCoupleInfoResult: Observable<CoupleInfo> = .just(CoupleInfo(firstMetDate: "", sinceMetDate: "", stage: ""))
    var setTermsResult: Observable<Bool> = .just(true)
    var soloStartResult: Observable<Bool> = .just(true)
    var assignCardsResult: Observable<Bool> = .just(true)
    var setOnboardingResult: Observable<String> = .just("닉네임")
    
    var assignCardsCallCount = 0
    
    func issueCode() -> Observable<CoupleCode> { issueCodeResult }
    func connectCouple(code: String) -> Observable<Bool> { connectCoupleResult }
    func updateNickname(nickname: String) -> Observable<String> { updateNicknameResult }
    func updateCoupleInfo(date: String, stage: String) -> Observable<CoupleInfo> { updateCoupleInfoResult }
    func setTerms(infoAgree: Bool?, marketingAgree: Bool?, advertiesmentAgree: Bool?) -> Observable<Bool> { setTermsResult }
    func soloStart() -> Observable<Bool> { soloStartResult }
    
    func assignCards(startDate: String, endDate: String) -> Observable<Bool> {
        assignCardsCallCount += 1
        return assignCardsResult
    }
    
    func setOnboarding(info: OnboardingInfo) -> Observable<String> { setOnboardingResult }
}
