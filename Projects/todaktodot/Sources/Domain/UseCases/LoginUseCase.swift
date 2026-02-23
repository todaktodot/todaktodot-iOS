//
//  LoginUseCase.swift
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

final class LoginUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(type: LoginType) -> Observable<Bool> {
        repository.login(type: type)
    }
    
    func fetchUserInfo() -> Observable<UserInfo> {
        repository.fetchUserInfo()
    }
    
    func loginTest() -> Observable<Bool> {
        return repository.loginTest()
    }
}
