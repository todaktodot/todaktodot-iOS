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
    case shareLink(coupleId: Int, date: String, cardId: Int)

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

        // Custom Scheme: todaktodot://share?...
        // Universal Link: https://todaktodot.com/share?...
        let isSharePath = components.host == "share" || components.path.contains("/share")
        guard isSharePath else { return nil }

        // 난독화된 data 파라미터 디코딩
        guard let encodedData = queryItems.first(where: { $0.name == "data" })?.value,
              let decodedData = Data(base64Encoded: encodedData),
              let json = try? JSONSerialization.jsonObject(with: decodedData) as? [String: Any],
              let coupleId = json["c"] as? Int,
              let date = json["d"] as? String,
              let cardId = json["k"] as? Int else { return nil }

        self = .shareLink(coupleId: coupleId, date: date, cardId: cardId)
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
        case .shareLink(let coupleId, let dateString, let cardId):
            // 1. 유효기간 확인 (공유일로부터 7일)
            if isLinkExpired(dateString: dateString) {
                showAlert(on: homeVC, title: "공유 링크가 만료되었어요.", description: "링크는 7일간 유효해요.")
                return
            }
            // 2. 현재 로그인된 사용자의 coupleId와 비교
            guard let myCoupleId = UserdefaultKey.coupleId, myCoupleId == coupleId else {
                showAlert(on: homeVC, title: "해당 히스토리 카드를 확인할 수 없어요.", description: "상대와 연결된 연인만 볼 수 있어요.")
                return
            }
            fetchAndNavigate(coupleCardId: cardId, coordinator: coordinator)
        }
    }

    private func isLinkExpired(dateString: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let sharedDate = formatter.date(from: dateString) else { return true }

        let calendar = Calendar.current
        guard let expirationDate = calendar.date(byAdding: .day, value: 7, to: sharedDate) else { return true }

        return Date() > expirationDate
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
