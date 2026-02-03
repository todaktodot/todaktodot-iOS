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
}
