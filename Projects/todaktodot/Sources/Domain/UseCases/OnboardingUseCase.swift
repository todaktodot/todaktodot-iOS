//
//  OnboardingUseCase.swift
//  todaktodot
//
//  Created by 임대진 on 7/7/26.
//

import Foundation
import RxSwift

final class OnboardingUseCase {
    private let repository: MypageRepository

    init(repository: MypageRepository) {
        self.repository = repository
    }
    
    func fetchInfo() -> Observable<MypageInfo> {
        repository.fetchInfo()
    }
    
    func logout() -> Observable<Void> {
        repository.logout()
    }
    
    func disconnectCouple() -> Observable<Bool> {
        repository.disconnectCouple()
    }
}
