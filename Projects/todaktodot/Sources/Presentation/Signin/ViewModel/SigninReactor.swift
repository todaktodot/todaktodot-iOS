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

enum ServerAuthError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case parsingError
    case serverClosed
}

final class SigninReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var isKakaoSigninTapped: Bool = false
        var isGoogleSigninTapped: Bool = false
//        var isAppleSigninTapped: Bool = false

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
        case setKakaoSigninTapped(Bool)
        case setGoogleSigninTapped(Bool)
//        case setAppleSigninTapped(Bool)
        
//        case setAppleLoginResult(Result<ASAuthorizationAppleIDCredential, Error>)
        case setKakaoSigninSuccess(Bool)
        case setGoogleSigninSuccess(Bool)
    }
    
    let initialState = State()
    private let kakaoLoginService = KakaoLoginService.shared
    private let googleLoginService = GoogleLoginService.shared

    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapKakaoButton:
            return kakaoLoginService.signIn()
                .map { Mutation.setKakaoSigninSuccess($0) }
        case .tapGoogleButton:
            return googleLoginService.signIn()
                .map { Mutation.setGoogleSigninSuccess($0) }
//        case .tapAppleButton:
//            print("tap apple")
//            appleLoginService.startSignInWithApple()
//            return appleLoginService.loginResult
//                .map{Mutation.setAppleLoginResult($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            case .setKakaoSigninTapped(let isTapped):
                newState.isKakaoSigninTapped = isTapped
            case .setGoogleSigninTapped(let isTapped):
                newState.isGoogleSigninTapped = isTapped
//            case .setAppleSigninTapped(let isTapped):
//                newState.isAppleSigninTapped = isTapped
               
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
