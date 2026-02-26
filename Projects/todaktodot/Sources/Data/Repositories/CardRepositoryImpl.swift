//
//  CardRepositoryImpl.swift
//  todaktodot
//
//  Created by daye on 2/7/26.
//

import Foundation
import RxSwift
import NetworkKit
import Alamofire

final class CardRepositoryImpl: CardRepository {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func selectCardType(coupleCardId: Int) -> Observable<Result<Void, Error>> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/select-type",
            method: .post,
            parameters: ["coupleCardId": coupleCardId]
        )
        
        return networkManager.request(with: endpoint)
            .map { _ in Result<Void, Error>.success(()) }
            .catch { error in .just(.failure(error)) }
    }
    
    func assignCards(startDate: String, endDate: String) -> Observable<Result<Void, Error>> {
        let endpoint = Endpoint<Empty>(
            baseURL: .todaktodotAPI,
//            path: "/api/daily-card/assign/me?startDate=\(startDate)&endDate=\(endDate)",
            path: "/api/daily-card/assign/me",
            method: .post,
            encodingType: .body,
            parameters: [
                "startDate": startDate,
                "endDate": endDate
            ]
        )
        
        return networkManager.request(with: endpoint)
            .map { _ in Result<Void, Error>.success(()) }
            .catch { error in .just(.failure(error)) }
    }

    func submitAnswers(coupleCardId: Int, cardId: Int, answers: [Answer]) -> Observable<Result<SubmitAnswerResult, Error>> {
        let request = SubmitAnswerRequestDTO(
            coupleCardId: coupleCardId,
            cardId: cardId,
            answers: answers.map { AnswerDTO(questionNo: $0.questionNo, answerContent: $0.content) }
        )
        
        let endpoint = Endpoint<SubmitAnswerResponseDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/answer",
            method: .post,
            parameters: request.toDictionary()
        )
        
        return networkManager.request(with: endpoint)
            .map { responseDTO in
                Result<SubmitAnswerResult, Error>.success(responseDTO.toEntity())
            }
            .catch { error in .just(.failure(error)) }
    }
    
    func fetchWeeklyCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>> {
        let endpoint = Endpoint<DailyCardResponseDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/weekly",
            method: .get,
            parameters: [
                "startDate": startDate,
                "endDate": endDate
            ]
        )
        
        return networkManager.request(with: endpoint)
            .map { responseDTO in
                Result<[QuestionCard], Error>.success(responseDTO.toEntity())
            }
            .catch { error in .just(.failure(error)) }
    }
    
    func fetchHistoryCards(startDate: String, endDate: String) -> Observable<Result<[QuestionCard], Error>> {
        let endpoint = Endpoint<CardHistoryResponseDTO>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/history/with-details2",
            method: .get,
            parameters: [
                "startDate": startDate,
                "endDate": endDate
            ]
        )
        
        return networkManager.request(with: endpoint)
            .map { responseDTO in
                Result<[QuestionCard], Error>.success(responseDTO.toEntity())
            }
            .catch { error in .just(.failure(error)) }
    }
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return [:]
        }
        return dict
    }
}
