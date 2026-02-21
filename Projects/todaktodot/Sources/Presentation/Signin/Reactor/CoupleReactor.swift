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
        var connectInfo: ConnectInfo?
        var isLoading: Bool = false
        var isJoined: Bool?
        
        var isAlreadyCouple: Bool?
        var isTermsAgreeSuccess: Bool = false
        var isCoupleConnectSuccess: Bool = false
        var isSoloStartSuccess: Bool = false
        var isMyCodeIssueFailed: Bool = false
        var isSoloStartFailed: Bool = false
        
        var updateNickname: String?
        var updateCoupleInfo: CoupleInfo?
    }
    
    enum Action {
        case issueCoupleCode
        case checkIsJoined
        case fetchConnectInfo
        case tapTemrsAgreeButton(Bool, Bool)
        case tapConnectButton(String)
        case tapNicknameButton(String)
        case tapStartButton(String, String)
        case tapSoloStartButton
    }
    
    enum Mutation {
        case setSoloStart(Bool)
        case setLoading(Bool)
        case setIsJoined(Bool)
        
        case setTermsAgreeSuccess(Bool)
        case setCoupleConnectSuccess(Bool)
        
        case setMyCode(String)
        case setNickname(String)
        case setCoupleInfo(CoupleInfo)
        case setConnectInfo(ConnectInfo)
        
        case setAlreadyCouple
        
        case setMyCodeIssueFailed
        case setSoloStartFailed
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
                .catch {
                    if let afError = $0.asCustomAFError, afError.isAlreadyCouple {
                        return .just(.setAlreadyCouple)
                    }
                    return .just(.setMyCodeIssueFailed) // TODO: 에러 처리
                }
        case .tapConnectButton(let code):
            return coupleUseCase.connectCouple(code: code)
                .map { Mutation.setCoupleConnectSuccess($0) }
                .catchAndReturn(Mutation.setCoupleConnectSuccess(false))
            
        case .tapNicknameButton(let nickname):
            return coupleUseCase.updateNickname(nickname: nickname)
                .map { Mutation.setNickname($0) }
            
        case .tapStartButton(let date, let stage):
            return coupleUseCase.updateCoupleInfo(date: date, stage: stage)
                .map { Mutation.setCoupleInfo($0) }
            
        case .tapTemrsAgreeButton(let isMarketing, let isAdvertiesment):
            return coupleUseCase.setTerms(marketingAgree: isMarketing, advertiesmentAgree: isAdvertiesment)
                .map { Mutation.setTermsAgreeSuccess($0) }
                .catchAndReturn(Mutation.setTermsAgreeSuccess(false))
            
        case .checkIsJoined:
            return .just(.setIsJoined(UserdefaultKey.joined))
            
        case .fetchConnectInfo:
            return coupleUseCase.fetchConnectInfo()
                .map { Mutation.setConnectInfo($0) }
            
        case .tapSoloStartButton:
            return coupleUseCase.soloStart()
                .map { Mutation.setSoloStart($0) }
                .catch {
                    if let afError = $0.asCustomAFError, afError.isAleardySolo {
                        return .just(.setSoloStart(true))
                    }
                    return .just(.setSoloStartFailed)
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setMyCode(let code):
            newState.mycode = code
            
        case .setTermsAgreeSuccess(let isSuccess):
            newState.isTermsAgreeSuccess = isSuccess
            
        case .setMyCodeIssueFailed:
            newState.isMyCodeIssueFailed = true
            
        case .setCoupleConnectSuccess(let isSuccess):
            newState.isCoupleConnectSuccess = isSuccess
            
        case .setNickname(let nickname):
            newState.updateNickname = nickname
            
        case .setCoupleInfo(let info):
            newState.updateCoupleInfo = info
            
        case .setIsJoined(let isJoined):
            newState.isJoined = isJoined
            
        case .setConnectInfo(let connectInfo):
            newState.connectInfo = connectInfo
            
        case .setAlreadyCouple:
            newState.isAlreadyCouple = true
            
        case .setSoloStart(let isSuccess):
            newState.isSoloStartSuccess = isSuccess
            
        case .setSoloStartFailed:
            newState.isSoloStartFailed = true
        }
        
        return newState
    }
}
