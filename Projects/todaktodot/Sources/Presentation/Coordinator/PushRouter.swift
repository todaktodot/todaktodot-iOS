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
        }
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
