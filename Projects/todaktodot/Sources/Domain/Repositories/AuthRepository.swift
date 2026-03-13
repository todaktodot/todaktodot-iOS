//
//  AuthRepository.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift

protocol AuthRepository {
    func login(type: LoginType) -> Observable<Bool>
    func fetchUserInfo() -> Observable<UserInfo>
    func updateDeviceToken(token: String?) -> Observable<Bool>
}
