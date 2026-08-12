//
//  VoteUseCase.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import Foundation
import RxSwift

final class VoteUseCase {
    private let repository: VoteRepository
    
    init(repository: VoteRepository) {
        self.repository = repository
    }
}
