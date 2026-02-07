//
//  CardRepositoryImpl.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import RxSwift
import NetworkKit
import Alamofire

final class CardRepositoryImpl: CardRepository {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func selectCardType(coupleCardId: Int) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/select-type",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: ["coupleCardId": coupleCardId]
        )
        return networkManager.request(with: endpoint).map { _ in true }
    }

    // 배정
    func assignCards(startDate: String, endDate: String) -> Observable<Bool> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/assign/me",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: [
                "startDate": startDate,
                "endDate": endDate
            ]
        )
        return networkManager.request(with: endpoint).map { _ in true }
    }

    // 답변제출
    func submitAnswers(coupleCardId: Int, cardId: Int, answers: [AnswerInput]) -> Observable<Bool> {
        let params: [String: Any] = [
            "coupleCardId": coupleCardId,
            "cardId": cardId,
            "answers": answers.map { ["questionNo": $0.no, "answerContent": $0.content] }
        ]
        
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/answer",
            method: .post,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: params
        )
        return networkManager.request(with: endpoint).map { _ in true }
    }
    
    // 주간 데일리 카드 조회 (user default 저장)
    func fetchWeeklyCards(startDate: String, endDate: String) -> Observable<[QuestionCard]> {
        let endpoint = Endpoint<DailyCardResponseDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/weekly",
            method: .get,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: [
                "startDate": startDate,
                "endDate": endDate
            ]
        )
        
        return networkManager.request(with: endpoint)
            .map { responseDTO in
                return responseDTO.toEntity()
            }
    }
    
    // 히스토리 카드 상세 리스트 조회
    func fetchHistoryCards(startDate: String, endDate: String) -> Observable<[QuestionCard]> {
        let endpoint = Endpoint<CardHistoryResponseDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/history/with-details",
            method: .get,
            headers: [.authorization(bearerToken: UserdefaultKey.accessToken)],
            parameters: [
                "startDate": startDate,
                "endDate": endDate
            ]
        )
        
        return networkManager.request(with: endpoint)
            .map { responseDTO in
                responseDTO.toEntity()
            }
    }
}


struct AnswerInput {
    let no: Int
    let content: String
}
