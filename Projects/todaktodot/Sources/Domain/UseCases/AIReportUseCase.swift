//
//  AIReportUseCase.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import RxSwift

final class AIReportUseCase {
    private let repository: AIReportRepository

    init(repository: AIReportRepository) {
        self.repository = repository
    }
    func fetchLastWeekAIReportCreated() -> Observable<AIReportCreated> {
        repository.fetchLastWeekAIReportCreated()
    }
    
    func fetchAIReportDetail(id: Int) -> Observable<AIReportDetail> {
        repository.fetchAIReportDetail(id: id)
    }
    
    func fetchAIReportList() -> Observable<[AIReportList]> {
        repository.fetchAIReportList()
    }
    
    func fetchHistoryCardDetail(coupleCardId: Int) -> Observable<QuestionCard?> {
        repository.fetchHistoryCardDetail(coupleCardId: coupleCardId)
    }
}
