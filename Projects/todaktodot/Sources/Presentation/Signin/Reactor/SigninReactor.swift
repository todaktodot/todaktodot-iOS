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
        var signinEvent: SigninEvent? = nil
    }

    enum SigninEvent {
        case kakaoSuccess
        case googleSuccess
        case appleSuccess
        case kakaoFail
        case googleFail
        case appleFail
    }
    
    enum Action {
        case tapKakaoButton
        case tapGoogleButton
        case tapAppleButton
        case clearEvent
        case tapTestButton
    }

    enum Mutation {
        case setLoading(Bool)
        case setSigninEvent(SigninEvent?)
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
                    .map { Mutation.setSigninEvent($0 ? .kakaoSuccess : .kakaoFail) }
                    .catch { _ in .just(.setSigninEvent(.kakaoFail)) },
                .just(.setLoading(false))
            ])
        case .tapGoogleButton:
            return Observable.concat([
                .just(.setLoading(true)),
                loginUseCase.execute(type: .google)
                    .map { Mutation.setSigninEvent($0 ? .googleSuccess : .googleFail) }
                    .catch { _ in .just(.setSigninEvent(.googleFail)) },
                .just(.setLoading(false))
            ])
        case .tapAppleButton:
            return Observable.concat([
                .just(.setLoading(true)),
                loginUseCase.execute(type: .apple)
                    .map { Mutation.setSigninEvent($0 ? .appleSuccess : .appleFail) }
                    .catch { _ in .just(.setSigninEvent(.appleFail)) },
                .just(.setLoading(false))
            ])
        case .clearEvent:
            return .just(.setSigninEvent(nil))
            
        case .tapTestButton:
            return Observable.concat([
                .just(.setLoading(true)),
                loginUseCase.loginTest()
                    .map { Mutation.setSigninEvent($0 ? .appleSuccess : .appleFail) }
                    .catch { _ in .just(.setSigninEvent(.appleFail)) },
                .just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setSigninEvent(let event):
            newState.signinEvent = event
        }
        return newState
    }
}
