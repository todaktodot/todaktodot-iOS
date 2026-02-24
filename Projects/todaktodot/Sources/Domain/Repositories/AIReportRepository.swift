//
//  AIReportRepository.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import RxSwift

protocol AIReportRepository {
    func fetchLastWeekAIReportCreated() -> Observable<AIReportCreated>
    func fetchAIReportDetail(id: Int) -> Observable<AIReportDetail>
    func fetchAIReportList() -> Observable<AIReportList>
}
