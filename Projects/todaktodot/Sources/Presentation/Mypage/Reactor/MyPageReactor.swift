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
    }
    
    enum Action {
        case fetchInfo
//        case tapTerms
        case tapLogout
        case tapDisconnectCouple
//        case tapWitdrawal
    }

    enum Mutation {
        case setInfo(MypageInfo)
        case setLoading(Bool)
        case setLogout(Bool)
        case setDisconnectCouple(Bool)
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
//        case .tapTerms:
            
        case .tapDisconnectCouple:
            return useCase.disconnectCouple()
                .map { .setDisconnectCouple($0) }
            
        case .tapLogout:
            return useCase.logout()
                .map { .setLogout($0) }
            
//        case .tapWitdrawal:
            
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
        }
        return newState
    }
}
