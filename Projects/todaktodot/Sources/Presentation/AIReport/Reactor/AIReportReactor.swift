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
        var reportData: (AIReportDetail, AIReportViewStep)?
        var storageData: [AIReportList]?
    }
    
    enum Action {
        case tapReportDetailButton
        case tapStorageReport(Int)
        case fetchStorageReportData
    }
    
    enum Mutation {
        case setReportSuccess(AIReportDetail, AIReportViewStep)
        case setStorageReport([AIReportList])
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
                .map { Mutation.setReportSuccess($0, .first) }
            
        case .tapStorageReport:
            return useCase.fetchAIReportDetail(id: 1)
                .map { Mutation.setReportSuccess($0, .history) }
            
        case .fetchStorageReportData:
            return useCase.fetchAIReportList()
                .map { Mutation.setStorageReport($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setReportSuccess(let report, let step):
            newState.reportData = (report, step)
        case .setStorageReport(let list):
            newState.storageData = list
        }
        return newState
    }
}
