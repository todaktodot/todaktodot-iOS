//
//  CoupleRepository.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift

protocol CoupleRepository {
    func issueCode() -> Observable<CoupleCode>
    func connectCouple(code: String) -> Observable<Bool>
    func setNickname(nickname: String) -> Observable<Bool>
    func setCoupleInfo(date: String, stage: String) -> Observable<Bool>
    func setTerms(marketingAgree: Bool) -> Observable<Bool>
}
