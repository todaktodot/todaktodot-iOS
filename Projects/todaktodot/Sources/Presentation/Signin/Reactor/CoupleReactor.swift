//
//  CoupleReactor.swift
//  todaktodot
//
//  Created by 임대진 on 2/3/26.
//

import RxSwift
import ReactorKit
import Foundation

final class CoupleReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var mycode: String?
        var isLoading: Bool = false
        var isJoined: Bool?
        
        var isAlreadyCouple: Bool?
        var isTermsAgreeSuccess: Bool?
        var isCoupleConnectSuccess: Bool?
        var isSoloStartSuccess: Bool?
        
        var updateNickname: String?
        var updateCoupleInfo: CoupleInfo?
        var error: Error?
    }
    
    enum Action {
        case issueCoupleCode
        case checkIsJoined
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
        
        case setAlreadyCouple
        case setError(Error?)
    }
    
    let initialState = State()
    
    private let coupleUseCase: CoupleUseCase
    
    init(coupleUseCase: CoupleUseCase) {
        self.coupleUseCase = coupleUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .issueCoupleCode:
            if UserdefaultKey.coupleType == .connected {
                return Observable.just(.setAlreadyCouple)
                    .observe(on: MainScheduler.asyncInstance)
            } else {
                return coupleUseCase.issueCode()
                    .map { Mutation.setMyCode($0.linkCode) }
                    .catch {
                        if let afError = $0.asCustomAFError, afError.isAlreadyCouple {
                            return .just(.setAlreadyCouple)
                        }
                        return .just(.setError($0))
                    }
            }
        case .tapConnectButton(let code):
            return coupleUseCase.connectCouple(code: code)
                .flatMap { _ -> Observable<Mutation> in
                    return self.assignCards()
                        .map { .setCoupleConnectSuccess($0) }
                        .catch { .just(.setError($0)) }
                }
                .catchAndReturn(.setCoupleConnectSuccess(false))
            
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
            
        case .tapSoloStartButton:
            if UserdefaultKey.coupleType != .null {
                return .just(.setSoloStart(true))
            } else {
                return coupleUseCase.soloStart()
                    .flatMap { _ -> Observable<Mutation> in
                        return self.assignCards()
                            .map { .setSoloStart($0) }
                            .catch { .just(.setError($0)) }
                    }
                    .catch {
                        if let afError = $0.asCustomAFError, afError.isAleardySolo {
                            return .just(.setSoloStart(true))
                        }
                        return .just(.setError($0))
                    }
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
            
        case .setCoupleConnectSuccess(let isSuccess):
            newState.isCoupleConnectSuccess = isSuccess
            
        case .setNickname(let nickname):
            newState.updateNickname = nickname
            
        case .setCoupleInfo(let info):
            newState.updateCoupleInfo = info
            
        case .setIsJoined(let isJoined):
            newState.isJoined = isJoined
            
        case .setAlreadyCouple:
            newState.isAlreadyCouple = true
            
        case .setSoloStart(let isSuccess):
            newState.isSoloStartSuccess = isSuccess
            
        case .setError(let error):
            newState.error = error
        }
        
        return newState
    }
    
    private func assignCards() -> Observable<Bool> {
        let now = Date()
        
        var calendar = Calendar.current
        
        if let timeZone = TimeZone(identifier: "Asia/Seoul") {
            calendar.timeZone = timeZone
        }
        
        let hour = calendar.component(.hour, from: now)
        
        guard let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: now),
              let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: now) else {
            assertionFailure("Date 계산 실패")
            return self.coupleUseCase.assignCards(
                startDate: now.toYYYYMMDD(),
                endDate: now.toYYYYMMDD()
            )
        }
        
        switch hour {
        case 0..<4:
            return self.coupleUseCase.assignCards(
                startDate: yesterdayDate.toYYYYMMDD(),
                endDate: tomorrowDate.toYYYYMMDD()
            )
        default:
            return self.coupleUseCase.assignCards(
                startDate: now.toYYYYMMDD(),
                endDate: tomorrowDate.toYYYYMMDD()
            )
        }
    }
}
