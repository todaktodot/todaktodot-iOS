//
//  MainTabBarCoordinator.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit
import RxSwift
import NetworkKit

final class TabBarCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let disposeBag = DisposeBag()
    private var tabBarController: MainTabBarController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = MainTabBarController()
        self.tabBarController = tabBarController
        
        setupChildCoordinators(tabBarController: tabBarController)
        
        navigationController.setViewControllers([tabBarController], animated: false)
    }
    
    func showCoupleConnect() {
        let signinCoordinator = SigninCoordinator(navigationController: navigationController)
        signinCoordinator.parentCoordinator = self
        addChild(signinCoordinator)
        signinCoordinator.showCoupleConnect()
    }
    
    private func setupChildCoordinators(tabBarController: MainTabBarController) {
        var viewControllers: [UIViewController] = []
        
        let homeNavController = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNavController)
        homeCoordinator.tabBarCoordinator = self
        addChild(homeCoordinator)
        homeCoordinator.start()
        viewControllers.append(homeNavController)
        
        let voteNavController = UINavigationController()
        let voteCoordinator = VoteCoordinator(navigationController: voteNavController)
        voteCoordinator.tabBarCoordinator = self
        addChild(voteCoordinator)
        voteCoordinator.start()
        viewControllers.append(voteNavController)
        
        let aiReportNavController = UINavigationController()
        let aiReportCoordinator = AIReportCoordinator(navigationController: aiReportNavController)
        aiReportCoordinator.tabBarCoordinator = self
        addChild(aiReportCoordinator)
        aiReportCoordinator.start()
        viewControllers.append(aiReportNavController)
        
        tabBarController.setViewControllers(viewControllers)
    }
}
