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
        var reportData: (AIReportDetail?, AIReportViewStep?)?
        var storageData: [AIReportList]?
        var historyData: QuestionCard?
        var reportCreated: AIReportCreated?
    }
    
    enum Action {
        case fetchReportIsCreated
        case fetchStorageListData
        
        case tapReportDetailButton(Int)
        case tapStorageReport(Int)
        case tapTopicCard(Int)
    }
    
    enum Mutation {
        case setReportSuccess(AIReportDetail?, AIReportViewStep?)
        case setStorageReport([AIReportList])
        case setReportCreated(AIReportCreated)
        case setHistoryDetail(QuestionCard?)
    }
    
    let initialState = State()
    
    private let useCase: AIReportUseCase
    
    init(useCase: AIReportUseCase) {
        self.useCase = useCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapReportDetailButton(let id):
            return Observable.concat([
                useCase.fetchAIReportDetail(id: id)
                    .map { Mutation.setReportSuccess($0, .first) },
                .just(Mutation.setReportSuccess(nil, nil))
            ])
            
        case .tapStorageReport(let id):
            return Observable.concat([
                useCase.fetchAIReportDetail(id: id)
                    .map { Mutation.setReportSuccess($0, .history) },
                .just(Mutation.setReportSuccess(nil, nil))
            ])
            
        case .fetchStorageListData:
            return useCase.fetchAIReportList()
                .map { Mutation.setStorageReport($0) }
            
        case .fetchReportIsCreated:
            return useCase.fetchLastWeekAIReportCreated()
                .map { Mutation.setReportCreated($0) }
            
        case .tapTopicCard(let id):
            return Observable.concat([
                useCase.fetchHistoryCardDetail(coupleCardId: id)
                    .map { Mutation.setHistoryDetail($0) },
                .just(Mutation.setHistoryDetail(nil))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setReportSuccess(let report, let step):
            newState.reportData = (report, step)
        case .setStorageReport(let list):
            newState.storageData = list
        case .setReportCreated(let created):
            newState.reportCreated = created
        case .setHistoryDetail(let history):
            newState.historyData = history
        }
        return newState
    }
}
