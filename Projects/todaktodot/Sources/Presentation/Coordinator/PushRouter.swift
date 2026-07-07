//
//  PushRouter.swift
//  todaktodot
//
//  Created by daye on 5/29/26.
//

import UIKit
import RxSwift

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
        container.makeShareLinkUseCase().validateShareLink(token: token)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success(let status):
                    switch status {
                    case .valid(let cardId):
                        self?.fetchAndNavigate(coupleCardId: cardId, coordinator: coordinator)
                    case .expired:
                        self?.showShareAlert(
                            on: homeVC,
                            title: "만료된 링크예요",
                            description: "유효기간이 만료되어\n메인 화면으로 이동합니다"
                        )
                    case .forbidden:
                        self?.showShareAlert(
                            on: homeVC,
                            title: "해당 히스토리 카드를 확인할 수 없어요",
                            description: "상대와 연결된 연인만 볼 수 있어요"
                        )
                    case .notFound:
                        self?.showShareAlert(
                            on: homeVC,
                            title: "존재하지 않는 링크예요",
                            description: "링크가 유효하지 않아\n메인 화면으로 이동합니다"
                        )
                    case .unknown:
                        self?.showShareAlert(
                            on: homeVC,
                            title: "알 수 없는 오류가 발생했어요",
                            description: "메인 화면으로 이동합니다"
                        )
                    }
                case .failure:
                    self?.showShareAlert(
                        on: homeVC,
                        title: "네트워크 오류가 발생했어요",
                        description: "잠시 후 다시 시도해주세요"
                    )
                }
            })
            .disposed(by: disposeBag)
    }

    private func showShareAlert(on viewController: UIViewController, title: String, description: String? = nil) {
        viewController.showAlert(
            icon: UIImage(named: "Bell"),
            title: title,
            description: description,
            primaryButtonTitle: "확인",
            primaryButtonAction: { [weak viewController] in
                // 홈(메인)으로 이동
                guard let nav = viewController?.navigationController else { return }
                nav.popToRootViewController(animated: true)
            },
            dimColor: UIColor(hex: "412360")
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
