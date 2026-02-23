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
    }

    enum Mutation {
        case setLoading(Bool)
        case setUserInfo(UserInfo)
        case setSigninFail(Bool)
    }
    
    let initialState = State()
    
    private let loginUseCase: LoginUseCase

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoButton:
            return Observable.concat([
                .just(.setLoading(true)),
                loginUseCase.execute(type: .kakao)
                    .flatMap { _ in
                        self.loginUseCase.fetchUserInfo()
                            .map { Mutation.setUserInfo($0) }
                    }
                    .catchAndReturn(.setSigninFail(true)),
                    .just(.setLoading(false))
            ])
            
        case .tapGoogleButton:
            return Observable.concat([
                .just(.setLoading(true)),
                loginUseCase.execute(type: .google)
                    .flatMap { _ in
                        self.loginUseCase.fetchUserInfo()
                            .map { Mutation.setUserInfo($0) }
                    }
                    .catchAndReturn(.setSigninFail(true)),
                    .just(.setLoading(false))
            ])
            
        case .tapAppleButton:
            return Observable.concat([
                .just(.setLoading(true)),
                loginUseCase.execute(type: .apple)
                    .flatMap { _ in
                        self.loginUseCase.fetchUserInfo()
                            .map { Mutation.setUserInfo($0) }
                    }
                    .catchAndReturn(.setSigninFail(true)),
                    .just(.setLoading(false))
            ])
            
        case .stopLoading:
            return .just(.setLoading(false))
            
        case .fetchUserInfo:
            return loginUseCase.fetchUserInfo()
                .map { Mutation.setUserInfo($0) }
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
        }
        return newState
    }
}
