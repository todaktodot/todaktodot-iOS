//
//  AIReportRepositoryImpl.swift
//  todaktodot
//
//  Created by 임대진 on 2/22/26.
//

import RxSwift
import NetworkKit
import Alamofire

final class AIReportRepositoryImpl: AIReportRepository {
    
    private let networkManager: NetworkManager
    
    init(
        networkManager: NetworkManager
    ) {
        self.networkManager = networkManager
    }
    
    func fetchLastWeekAIReportCreated() -> Observable<AIReportCreated> {
        let endpoint = Endpoint<AIReportCreated>(
            baseURL: .todaktodotAPI,
            path: "/api/ai-report",
            method: .post
        )

        return networkManager.request(with: endpoint)
            .map { $0 }
    }
    
    func fetchAIReportDetail(id: Int) -> Observable<AIReportDetail> {
//        let endpoint = Endpoint<AIReportDetail>(
//            baseURL: .todaktodotAPI,
//            path: "/api/ai-report/detail/\(id)",
//            method: .get
//        )
//
//        return networkManager.request(with: endpoint)
//            .map { $0 }
        return .just(AIReportDetailDTO.mock.toDetail())
    }
    
    func fetchAIReportList() -> Observable<[AIReportList]> {
//        let endpoint = Endpoint<AIReportList>(
//            baseURL: .todaktodotAPI,
//            path: "/api/ai-report/list",
//            method: .get
//        )
//
//        return networkManager.request(with: endpoint)
//            .map { $0 }
        return .just(AIReportList.mock)
    }
}
