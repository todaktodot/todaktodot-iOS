//
//  SigninReactor.swift
//  todaktodot
//
//  Created by 임대진 on 12/9/25.
//

import Alamofire
import Foundation
import RxSwift
import AuthenticationServices
import ReactorKit

final class SigninReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var isLoading: Bool = false

        // 변경될수도?
//        var appleLoginResult: Result<ASAuthorizationAppleIDCredential, Error>?
        var isKakaoSigninSuccess: Bool = false
        var isGoogleSigninSuccess: Bool = false
    }
    
    enum Action {
        case tapKakaoButton
        case tapGoogleButton
//        case tapAppleButton
    }
    
    enum Mutation {
        case setLoading(Bool)
        
//        case setAppleLoginResult(Result<ASAuthorizationAppleIDCredential, Error>)
        case setKakaoSigninSuccess(Bool)
        case setGoogleSigninSuccess(Bool)
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
                    .map { Mutation.setKakaoSigninSuccess($0) },
                .just(.setLoading(false))
            ])
        case .tapGoogleButton:
            return Observable.concat([
                .just(.setLoading(true)),
                loginUseCase.execute(type: .google)
                    .map { Mutation.setGoogleSigninSuccess($0) },
                .just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            case .setLoading(let isLoading):
                newState.isLoading = isLoading
               
//            case .setAppleLoginResult(let result):
//                newState.appleLoginResult = result
            case .setKakaoSigninSuccess(let isSuccess):
                newState.isKakaoSigninSuccess = isSuccess
            case .setGoogleSigninSuccess(let isSuccess):
                newState.isGoogleSigninSuccess = isSuccess
        }
        
        return newState
    }
}
