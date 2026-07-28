//
//  MockAuthRepository.swift
//  todaktodotTests
//
//  Created by daye on 7/28/26.
//

import RxSwift
@testable import todaktodot

final class MockAuthRepository: AuthRepository {
    
    var loginResult: Observable<Bool> = .just(true)
    var fetchUserInfoResult: Observable<UserInfo> = .just(UserInfo(
        userId: 1,
        coupleId: 1,
        isTerm: true,
        isCouple: true,
        coupleType: .connected,
        createdMyNickname: true,
        createdCoupleInfo: true,
        nicknameInfo: NicknameInfo(userNickname: "나", anotherUserNickname: "상대")
    ))
    var updateDeviceTokenResult: Observable<Bool> = .just(true)
    
    var fetchUserInfoCallCount = 0
    
    func login(type: LoginType) -> Observable<Bool> { loginResult }
    
    func fetchUserInfo() -> Observable<UserInfo> {
        fetchUserInfoCallCount += 1
        return fetchUserInfoResult
    }
    
    func updateDeviceToken(token: String?) -> Observable<Bool> { updateDeviceTokenResult }
}
