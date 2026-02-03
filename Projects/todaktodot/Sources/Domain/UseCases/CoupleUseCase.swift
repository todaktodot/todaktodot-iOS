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
    
    func setNickname(nickname: String) -> Observable<Bool> {
        repository.setNickname(nickname: nickname)
    }
    
    func setCoupleInfo(date: String, stage: String) -> Observable<Bool> {
        repository.setCoupleInfo(date: date, stage: stage)
    }
}
