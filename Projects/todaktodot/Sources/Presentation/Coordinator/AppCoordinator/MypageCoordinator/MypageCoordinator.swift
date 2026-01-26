//
//  MypageCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit

final class MypageCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MypageViewContorller()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
