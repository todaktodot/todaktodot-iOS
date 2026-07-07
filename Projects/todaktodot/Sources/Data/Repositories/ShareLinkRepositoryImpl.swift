//
//  ShareLinkRepositoryImpl.swift
//  todaktodot
//
//  Created by daye on 7/7/26.
//

import RxSwift
import NetworkKit

final class ShareLinkRepositoryImpl: ShareLinkRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func createShareLink(coupleCardId: Int) -> Observable<Result<ShareLink, Error>> {
        let endpoint = Endpoint<ShareLinkResponse>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/history/share-link",
            method: .post,
            parameters: ["coupleCardId": coupleCardId]
        )

        return networkManager.request(with: endpoint)
            .map { response in
                let entity = ShareLink(
                    shareUrl: response.shareUrl,
                    shareToken: response.shareToken,
                    expiredAt: response.expiredAt
                )
                return .success(entity)
            }
            .catch { error in
                .just(.failure(error))
            }
    }

    func validateShareLink(token: String) -> Observable<Result<ShareLinkStatus, Error>> {
        let endpoint = Endpoint<ShareLinkValidateResponse>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/history/share-link/validate",
            method: .post,
            parameters: ["shareToken": token]
        )

        return networkManager.request(with: endpoint)
            .map { response in
                let status: ShareLinkStatus
                switch response.status {
                case "VALID":
                    guard let cardId = response.coupleCardId else {
                        status = .unknown(message: "coupleCardId 없음")
                        return .success(status)
                    }
                    status = .valid(coupleCardId: cardId)
                case "EXPIRED":
                    status = .expired(message: response.message)
                case "FORBIDDEN":
                    status = .forbidden(message: response.message)
                case "NOT_FOUND":
                    status = .notFound(message: response.message)
                default:
                    status = .unknown(message: response.message)
                }
                return .success(status)
            }
            .catch { error in
                .just(.failure(error))
            }
    }
}
