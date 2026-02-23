//
//  AIReportReactor.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import RxSwift
import ReactorKit

final class AIReportReactor: Reactor {
    let disposeBag = DisposeBag()
    
    struct State {
        var currentStep: DetailStep = .syncReport
        var reportData: AIReportDetail?
    }
    
    enum DetailStep {
        case syncReport
        case insightReport
        case topicReport
    }
    
    enum Action {
        case tapReportDetailButton
        case tapNextButton
    }
    
    enum Mutation {
        case setReportSuccess(AIReportDetail)
        case setNextStep
    }
    
    let initialState = State()
    
    private let useCase: AIReportUseCase
    
    init(useCase: AIReportUseCase) {
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapReportDetailButton:
            return useCase.fetchAIReportDetail(id: 1)
                .map { Mutation.setReportSuccess($0) }
        case .tapNextButton:
            return .just(.setNextStep)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setReportSuccess(let report):
            newState.reportData = report
        case .setNextStep:
            switch state.currentStep {
            case .syncReport:
                newState.currentStep = .insightReport
            case .insightReport:
                newState.currentStep = .topicReport
            case .topicReport:
                newState.currentStep = .insightReport
            }
        }
        
        return newState
    }
}
