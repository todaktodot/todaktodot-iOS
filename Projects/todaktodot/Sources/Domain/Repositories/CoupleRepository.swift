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
    func updateNickname(nickname: String) -> Observable<String>
    func updateCoupleInfo(date: String, stage: String) -> Observable<CoupleInfo>
    func setTerms(infoAgree: Bool?, marketingAgree: Bool?, advertiesmentAgree: Bool?) -> Observable<Bool>
    func soloStart() -> Observable<Bool>
}
