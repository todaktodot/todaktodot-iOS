//
//  Coordinator +.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit

extension Coordinator {
    func navigateToMyPage(_ navigationController: UINavigationController?, tabBarCoordinator: TabBarCoordinator?) {
        guard let navigationController else { return }
        let coordinator = MypageCoordinator(navigationController: navigationController)
        coordinator.tabBarCoordinator = tabBarCoordinator
        addChild(coordinator)
        coordinator.start()
    }
}
