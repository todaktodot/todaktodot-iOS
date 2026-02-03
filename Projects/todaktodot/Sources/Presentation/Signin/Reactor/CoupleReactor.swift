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
        
        var isTermsAgreeSuccess: Bool = false
        var isCoupleConnectSuccess: Bool = false
        var isNicknameSetSuccess: Bool = false
        var isJoinSuccess: Bool = false
        
        var isMyCodeIssueFailed: Bool = false
    }
    
    enum Action {
        case issueCoupleCode
        //        case tapTemrsAgreeButton
        case tapConnectButton(String)
        case tapNicknameButton(String)
        case tapJoinButton(String, String)
    }
    
    enum Mutation {
        case setLoading(Bool)
        
        case setMyCode(String)
        case setTermsAgreeSuccess(Bool)
        case setCoupleConnectSuccess(Bool)
        case setNicknameSuccess(Bool)
        case setJoinSuccess(Bool)
        
        case setMyCodeIssueFailed
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
            
        case .tapConnectButton(let code):
            return coupleUseCase.connectCouple(code: code)
                .map { Mutation.setCoupleConnectSuccess($0) }
                .catchAndReturn(Mutation.setCoupleConnectSuccess(false))
            
        case .tapNicknameButton(let nickname):
            return coupleUseCase.setNickname(nickname: nickname)
                .map { Mutation.setNicknameSuccess($0) }
                .catchAndReturn(Mutation.setNicknameSuccess(false))
        case .tapJoinButton(let date, let stage):
            return coupleUseCase.setCoupleInfo(date: date, stage: stage)
                .map { Mutation.setJoinSuccess($0) }
                .catchAndReturn(Mutation.setJoinSuccess(false))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setMyCode(let code):
            newState.mycode = code
            
        case .setTermsAgreeSuccess(_):
            break
            
        case .setMyCodeIssueFailed:
            newState.isMyCodeIssueFailed = true
            
        case .setCoupleConnectSuccess(let isSuccess):
            newState.isCoupleConnectSuccess = isSuccess
            
        case .setNicknameSuccess(let isSuccess):
            newState.isNicknameSetSuccess = isSuccess
            
        case .setJoinSuccess(let isSuccess):
            newState.isJoinSuccess = isSuccess
        }
        
        return newState
    }
}
