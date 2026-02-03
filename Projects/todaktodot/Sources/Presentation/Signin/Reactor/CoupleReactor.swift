//
//  CoupleReactor.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import ReactorKit

final class CoupleReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var mycode: String?
        var isLoading: Bool = false
        var isMyCodeIssueFailed: Bool = false
        var isTermsAgreeSuccess: Bool = false
        var isCoupleConnectSuccess: Bool = false
    }
    
    enum Action {
        case issueCoupleCode
//        case tapTemrsAgreeButton
//        case tapConnectButton
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setMyCode(String)
        case setMyCodeIssueFailed
        case setTermsAgreeSuccess(Bool)
        case setCoupleConnectSuccess(Bool)
    }
    
    let initialState = State()
    
    private let coupleUseCase: CoupleUseCase

    init(coupleUseCase: CoupleUseCase) {
        self.coupleUseCase = coupleUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .issueCoupleCode:
            return coupleUseCase.issueCode()
                .map { Mutation.setMyCode($0.linkCode) }
                .catchAndReturn(Mutation.setMyCodeIssueFailed)
//        case .tapTemrsAgreeButton:
//            return Observable.concat([
//                .just(.setLoading(true)),
//                loginUseCase.execute(type: .kakao)
//                    .map { Mutation.setKakaoSigninSuccess($0) },
//                .just(.setLoading(false))
//            ])
//        case .tapConnectButton:
//            return Observable.concat([
//                .just(.setLoading(true)),
//                loginUseCase.execute(type: .google)
//                    .map { Mutation.setGoogleSigninSuccess($0) },
//                .just(.setLoading(false))
//            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            case .setLoading(let isLoading):
                newState.isLoading = isLoading
               
            case .setMyCode(let code):
                newState.mycode = code
//            case .setKakaoSigninSuccess(let isSuccess):
//                newState.isKakaoSigninSuccess = isSuccess
//            case .setGoogleSigninSuccess(let isSuccess):
//                newState.isGoogleSigninSuccess = isSuccess
            case .setMyCodeIssueFailed:
                newState.isMyCodeIssueFailed = true
            case .setTermsAgreeSuccess(_):
                break
            case .setCoupleConnectSuccess(_):
                break
        }
        
        return newState
    }
}
