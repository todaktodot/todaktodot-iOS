//
//  VoteReactor.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import RxSwift
import ReactorKit

final class VoteReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
    }
    
    enum Action {
    }
    
    enum Mutation {
    }
    
    let initialState = State()
    
    private let useCase: VoteUseCase
    
    init(useCase: VoteUseCase) {
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
