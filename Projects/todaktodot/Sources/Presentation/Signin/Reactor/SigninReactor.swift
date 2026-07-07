//
//  SigninReactor.swift
//  todaktodot
//
//  Created by 임대진 on 12/9/25.
//

import RxSwift
import AuthenticationServices
import ReactorKit

final class SigninReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var isLoading: Bool = false
        var isSigninFail: Bool?
        @Pulse var signinInfo: UserInfo?
    }
    
    enum Action {
        case tapKakaoButton
        case tapGoogleButton
        case tapAppleButton
        case stopLoading
        case fetchUserInfo
        case handlePendingCoupleDisconnect
    }

    enum Mutation {
        case setLoading(Bool)
        case setUserInfo(UserInfo)
        case setSigninFail(Bool)
        case none
    }
    
    let initialState = State()
    
    private let signinUseCase: SigninUseCase
    private let onboardingUseCase: OnboardingUseCase

    init(signinUseCase: SigninUseCase, onboardingUseCase: OnboardingUseCase) {
        self.signinUseCase = signinUseCase
        self.onboardingUseCase = onboardingUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoButton:
            UserdefaultKey.isKakaoLoginInProgress = true
            return socialLogin(type: .kakao)
            
        case .tapGoogleButton:
            return socialLogin(type: .google)
            
        case .tapAppleButton:
            return socialLogin(type: .apple)
            
        case .stopLoading:
            return .just(.setLoading(false))
            
        case .fetchUserInfo:
            return signinUseCase.fetchUserInfo()
                .map { Mutation.setUserInfo($0) }
        case .handlePendingCoupleDisconnect:
            return Observable.concat([
                onboardingUseCase.disconnectCouple()
                    .flatMap { _ in
                        self.onboardingUseCase.logout()
                    }
                    .do(onNext: {
                        UserdefaultKey.pendingCoupleDisconnect = false
                    })
                    .map { _ in
                        .none
                    }
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setUserInfo(let info):
            newState.signinInfo = info
        case .setSigninFail(let isFail):
            newState.isSigninFail = isFail
        case .none:
            break
        }
        return newState
    }
    
    private func socialLogin(type: LoginType) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            signinUseCase.execute(type: type)
                .flatMap { _ in
                    self.signinUseCase.updateDeviceToken(token: UserdefaultKey.diviceToken)
                        .catch { error in
                            print("FCM token update failed \(error.localizedDescription)")
                            return .just(false)
                        }
                }
                .flatMap { _ in
                    self.signinUseCase.fetchUserInfo()
                        .map { Mutation.setUserInfo($0) }
                }
                .catchAndReturn(.setSigninFail(true)),
            .just(.setLoading(false))
        ])
    }
}
