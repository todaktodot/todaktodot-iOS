//
//  MyPageReactor.swift
//  todaktodot
//
//  Created by 임대진 on 2/14/26.
//

import RxSwift
import AuthenticationServices
import ReactorKit

final class MyPageReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var info: MypageInfo?
        var isLoading: Bool = true
        var isLogout: Bool?
        var isDisconnectCouple: Bool?
        var isWithdrawal: Bool?
        var isInfoNotice: Bool?
        var isAdvertNoti: Bool?
        var isMarketingNoti: Bool?
    }
    
    enum Action {
        case fetchInfo
        case tapLogout
        case tapDisconnectCouple
        case tapWitdrawal
        case tapInfoNoti(Bool)
        case tapAdvertNoti(Bool)
        case tapMarketingNoti(Bool)
    }

    enum Mutation {
        case setInfo(MypageInfo)
        case setLoading(Bool)
        case setLogout(Bool)
        case setDisconnectCouple(Bool)
        case setWithdrawal(Bool)
        case setInfoNoti(Bool)
        case setAdvertNoti(Bool)
        case setMarketingNoti(Bool)
    }
    
    let initialState = State()
    
    private let useCase: MypageUsecase

    init(mypageUsecase: MypageUsecase) {
        self.useCase = mypageUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchInfo:
            return Observable.concat([
                useCase.fetchInfo()
                    .map { Mutation.setInfo($0) },
                .just(.setLoading(false))
            ])
            .catchAndReturn(.setLoading(false))
            
        case .tapDisconnectCouple:
            return useCase.disconnectCouple()
                .map { .setDisconnectCouple($0) }
            
        case .tapLogout:
            return useCase.logout()
                .flatMap { _ in
                    self.useCase.deleteDeviceToken()
                }
                .map { _ in .setLogout(true) }
                .catch { _ in
                    .just(.setLogout(true))
                }
            
        case .tapWitdrawal:
            return useCase.withdrawal()
                .map { .setWithdrawal($0) }
            
        case .tapInfoNoti(let isOn):
            return useCase.updateTerms(infoAgree: isOn)
                .map { .setInfoNoti($0) }
            
        case .tapAdvertNoti(let isOn):
            return useCase.updateTerms(advertiesmentAgree: isOn)
                .map { .setAdvertNoti($0) }
            
        case .tapMarketingNoti(let isOn):
            return useCase.updateTerms(marketingAgree: isOn)
                .map { .setMarketingNoti($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setInfo(let info):
            newState.info = info
        case .setDisconnectCouple(let isSuccess):
            newState.isDisconnectCouple = isSuccess
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setLogout(let success):
            newState.isLogout = success
        case .setWithdrawal(let success):
            newState.isWithdrawal = success
        case .setInfoNoti(let isOn):
            newState.isInfoNotice = isOn
        case .setAdvertNoti(let isOn):
            newState.isAdvertNoti = isOn
        case .setMarketingNoti(let isOn):
            newState.isMarketingNoti = isOn
        }
        return newState
    }
}
