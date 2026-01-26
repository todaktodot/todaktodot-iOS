//
//  Coordinator +.swift
//  todaktodot
//
//  Created by 임대진 on 1/24/26.
//

import UIKit

extension Coordinator {
    func navigateToMyPage(_ navigationController: UINavigationController?) {
        guard let navigationController else { return }
        let coordinator = MypageCoordinator(navigationController: navigationController)
        addChild(coordinator)
        coordinator.start()
    }
}
