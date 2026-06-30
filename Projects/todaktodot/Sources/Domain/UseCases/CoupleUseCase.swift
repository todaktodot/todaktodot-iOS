//
//  CoupleUseCase.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import Foundation
import RxSwift

final class CoupleUseCase {
    private let repository: CoupleRepository

    init(repository: CoupleRepository) {
        self.repository = repository
    }
    
    func issueCode() -> Observable<CoupleCode> {
        repository.issueCode()
    }
    
    func connectCouple(code: String) -> Observable<Bool> {
        repository.connectCouple(code: code)
    }
    
    func setTerms(infoAgree: Bool? = nil, marketingAgree: Bool? = nil, advertiesmentAgree: Bool? = nil) -> Observable<Bool> {
        repository.setTerms(infoAgree: infoAgree, marketingAgree: marketingAgree, advertiesmentAgree: advertiesmentAgree)
    }
    
    func updateNickname(nickname: String) -> Observable<String> {
        repository.updateNickname(nickname: nickname)
    }
    
    func updateCoupleInfo(date: String, stage: String) -> Observable<CoupleInfo> {
        repository.updateCoupleInfo(date: date, stage: stage)
    }
    
    func soloStart() -> Observable<Bool> {
        repository.soloStart()
    }
    
    func assignCards(startDate: String, endDate: String) -> Observable<Bool> {
        repository.assignCards(startDate: startDate, endDate: endDate)
    }
    
    func setOnboarding(info: OnboardingInfo) -> Observable<String> {
        repository.setOnboarding(info: info)
    }
}
