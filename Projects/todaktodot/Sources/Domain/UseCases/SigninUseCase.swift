//
//  SigninUseCase.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import Foundation
import RxSwift

enum LoginType: String {
    case kakao
    case google
    case apple
}

final class SigninUseCase {
    private let repository: AuthRepository
    private let mypageRepository: MypageRepository

    init(repository: AuthRepository, mypageRepository: MypageRepository) {
        self.repository = repository
        self.mypageRepository = mypageRepository
    }
    
    func execute(type: LoginType) -> Observable<Bool> {
        repository.login(type: type)
    }
    
    func fetchUserInfo() -> Observable<UserInfo> {
        repository.fetchUserInfo()
    }
    
    func updateDeviceToken(token: String?) -> Observable<Bool> {
        return repository.updateDeviceToken(token: token)
    }
    
    func logout() -> Observable<Void> {
        mypageRepository.logout()
    }
    
    func disconnectCouple() -> Observable<Bool> {
        mypageRepository.disconnectCouple()
    }
}
