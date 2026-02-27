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
//        let endpoint = Endpoint<AIReportCreated>(
//            baseURL: .todaktodotAPI,
//            path: "/api/ai-report",
//            method: .post
//        )
//
//        return networkManager.request(with: endpoint)
//            .map { $0 }
        return .just(AIReportCreated.mock)
    }
    
    func fetchAIReportDetail(id: Int) -> Observable<AIReportDetail> {
//        let endpoint = Endpoint<AIReportDetailDTO>(
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
        let endpoint = Endpoint<[AIReportListDTO]>(
            baseURL: .todaktodotAPI,
            path: "/api/ai-report/list",
            method: .get
        )

        return networkManager.request(with: endpoint)
            .map { $0.map { $0.toAIReportList() } }
    }
    
    func fetchHistoryCardDetail(coupleCardId: Int) -> Observable<QuestionCard?> {
        let parameters = [
            "coupleCardId" : coupleCardId
        ]
        
        let endpoint = Endpoint<CardHistoryResponseDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/history/detail",
            method: .get,
            encodingType: .query,
            parameters: parameters
        )

        return networkManager.request(with: endpoint)
            .map { $0.toEntity().first }
    }
}
