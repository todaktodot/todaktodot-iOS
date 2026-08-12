//
//  VoteCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import UIKit
import NetworkKit

final class VoteCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var tabBarCoordinator: TabBarCoordinator?
    private let container = AppDIContainer.shared
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = VoteViewController()
        vc.coordinator = self
        vc.reactor = container.makeVoteReactor()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showMakeVote() {
        let vc = UIViewController()
        navigationController.pushViewController(vc, animated: true)
    }
}
