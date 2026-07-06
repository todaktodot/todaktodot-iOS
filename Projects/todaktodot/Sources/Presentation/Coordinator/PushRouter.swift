//
//  PushRouter.swift
//  todaktodot
//
//  Created by daye on 5/29/26.
//

import UIKit
import RxSwift
import NetworkKit

enum PushDeepLink {
    case historyCardDetail(coupleCardId: Int)
    case shareLink(token: String)

    init?(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String else { return nil }

        switch type {
        case "EMOJI_REACTION":
            guard let idStr = userInfo["coupleCardId"] as? String,
                  let id = Int(idStr) else { return nil }
            self = .historyCardDetail(coupleCardId: id)
        default:
            return nil
        }
    }

    // Universal Link / Custom URL Scheme 초기화
    init?(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }

        // Universal Link: https://도메인/share/card?token=xxx
        // Custom Scheme: todaktodot://share/card?token=xxx
        let isSharePath = components.path.contains("/share/card") || components.host == "share"
        guard isSharePath else { return nil }

        guard let token = queryItems.first(where: { $0.name == "token" })?.value else { return nil }
        self = .shareLink(token: token)
    }
}

final class PushRouter {
    static let shared = PushRouter()
    private var disposeBag = DisposeBag()
    private let container = AppDIContainer.shared
    
    private(set) var pendingDeepLink: PushDeepLink?
    
    func route(userInfo: [AnyHashable: Any]) {
        guard let deepLink = PushDeepLink(userInfo: userInfo) else { return }

        if findTabBar() != nil {
            navigate(deepLink: deepLink)
        } else {
            pendingDeepLink = deepLink
        }
    }

    // Universal Link용
    func route(url: URL) {
        guard let deepLink = PushDeepLink(url: url) else { return }

        if findTabBar() != nil {
            navigate(deepLink: deepLink)
        } else {
            pendingDeepLink = deepLink
        }
    }
    
    func consumePending() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        navigate(deepLink: deepLink)
    }
    
    private func navigate(deepLink: PushDeepLink) {
        guard let tabBar = findTabBar() else { return }

        tabBar.selectTab(index: 0)

        guard let homeNav = tabBar.viewController(at: 0) as? UINavigationController,
              let homeVC = homeNav.viewControllers.first as? HomeViewController,
              let coordinator = homeVC.coordinator else { return }

        homeNav.popToRootViewController(animated: false)

        switch deepLink {
        case .historyCardDetail(let coupleCardId):
            fetchAndNavigate(coupleCardId: coupleCardId, coordinator: coordinator)
        case .shareLink(let token):
            validateShareLink(token: token, homeVC: homeVC, coordinator: coordinator)
        }
    }

    private func validateShareLink(token: String, homeVC: UIViewController, coordinator: HomeCoordinator) {
        let endpoint = Endpoint<ShareLinkValidateResponse>(
            baseURL: .todaktodotAPI,
            path: "/api/daily-card/history/share-link/validate",
            method: .post,
            parameters: ["shareToken": token]
        )
        
        container.makeNetworkManager().request(with: endpoint)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                switch response.status {
                case "VALID":
                    guard let cardId = response.coupleCardId else { return }
                    self?.fetchAndNavigate(coupleCardId: cardId, coordinator: coordinator)
                case "EXPIRED":
                    self?.showAlert(on: homeVC, title: "공유 링크가 만료되었어요.", description: "링크는 7일간 유효해요.")
                case "FORBIDDEN":
                    self?.showAlert(on: homeVC, title: "해당 히스토리 카드를 확인할 수 없어요.", description: response.message ?? "접근 권한이 없습니다.")
                case "NOT_FOUND":
                    self?.showAlert(on: homeVC, title: "존재하지 않는 링크예요.", description: response.message ?? "")
                default:
                    self?.showAlert(on: homeVC, title: "알 수 없는 오류가 발생했어요.")
                }
            }, onError: { [weak self] _ in
                self?.showAlert(on: homeVC, title: "네트워크 오류가 발생했어요.", description: "잠시 후 다시 시도해주세요.")
            })
            .disposed(by: disposeBag)
    }

    private func showAlert(on viewController: UIViewController, title: String, description: String? = nil) {
        viewController.showAlert(
            icon: UIImage(named: "Bell"),
            title: title,
            description: description,
            primaryButtonTitle: "확인",
            primaryButtonAction: {}
        )
    }
    
    private func fetchAndNavigate(coupleCardId: Int, coordinator: HomeCoordinator) {
        // 이전 구독 해제
        disposeBag = DisposeBag()
        
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = CardService.shared.getCardSystemDate()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let startOfWeek = calendar.date(from: components) else { return }
        
        container.makeCardUseCase()
            .fetchHistoryCards(startDate: startOfWeek.toYYYYMMDD(), endDate: today.toYYYYMMDD())
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { result in
                guard case .success(let cards) = result,
                      let card = cards.first(where: { $0.coupleCardId == coupleCardId }) else { return }
                coordinator.showHistoryCardDetail(card: card)
            })
            .disposed(by: disposeBag)
    }
    
    private func findTabBar() -> MainTabBarController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let rootNav = window.rootViewController as? UINavigationController,
              let tabBar = rootNav.viewControllers.first as? MainTabBarController else { return nil }
        return tabBar
    }
}
