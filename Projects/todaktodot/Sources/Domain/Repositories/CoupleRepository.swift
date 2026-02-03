//
//  CoupleRepository.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift

protocol CoupleRepository {
    func issueCode() -> Observable<CoupleCode>
    func linkCouple() -> Observable<Bool>
}
