//
//  MypageUsecase.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import Foundation
import RxSwift

final class MypageUsecase {
    private let repository: MypageRepository

    init(repository: MypageRepository) {
        self.repository = repository
    }
    
    func fetchInfo() -> Observable<MypageInfo> {
        repository.fetchInfo()
    }
    
    func logout() -> Observable<Bool> {
        repository.logout()
    }
    
    func disconnectCouple() -> Observable<Bool> {
        repository.disconnectCouple()
    }
    
    func withdrawal() -> Observable<Bool> {
        repository.withdrawal()
    }
}
