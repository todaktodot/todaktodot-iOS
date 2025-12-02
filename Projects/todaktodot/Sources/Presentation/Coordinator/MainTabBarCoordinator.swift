//
//  MainTabBarCoordinator.swift
//  todaktodot
//
//  Created by daye on 11/25/25.
//

import UIKit
import RxSwift

final class MainTabBarCoordinator: Coordinator {
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
    
    private func setupChildCoordinators(tabBarController: MainTabBarController) {
        var viewControllers: [UIViewController] = []
        
        let homeNavController = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNavController)
        addChild(homeCoordinator)
        homeCoordinator.start()
        viewControllers.append(homeNavController)
        
        let aiReportNavController = UINavigationController()
        let aiReportCoordinator = AIReportCoordinator(navigationController: aiReportNavController)
        addChild(aiReportCoordinator)
        aiReportCoordinator.start()
        viewControllers.append(aiReportNavController)
        
        tabBarController.setViewControllers(viewControllers)
    }
}

final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeViewController = HomeViewController()
        homeViewController.view.backgroundColor = TodotColors.Background.primary
        navigationController.navigationBar.isHidden = false
        navigationController.setViewControllers([homeViewController], animated: false)
    }
}

final class AIReportCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let aiReportViewController = UIViewController()
        aiReportViewController.view.backgroundColor = TodotColors.Background.primary
        aiReportViewController.title = "AI 리포트"
        navigationController.setViewControllers([aiReportViewController], animated: false)
    }
}
