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
    
    func showSignin() {
        let signinCoordinator = SigninCoordinator(navigationController: navigationController)
        signinCoordinator.parentCoordinator = self
        addChild(signinCoordinator)
        signinCoordinator.start()
    }
    
    private func setupChildCoordinators(tabBarController: MainTabBarController) {
        var viewControllers: [UIViewController] = []
        
        let homeNavController = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNavController)
        homeCoordinator.tabBarCoordinator = self
        addChild(homeCoordinator)
        homeCoordinator.start()
        viewControllers.append(homeNavController)
        
        let aiReportNavController = UINavigationController()
        let aiReportCoordinator = AIReportCoordinator(navigationController: aiReportNavController)
        aiReportCoordinator.tabBarCoordinator = self
        addChild(aiReportCoordinator)
        aiReportCoordinator.start()
        viewControllers.append(aiReportNavController)
        
        tabBarController.setViewControllers(viewControllers)
    }
}

final class HomeCoordinator: Coordinator {
    let networkManager = NetworkManager.shared
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var tabBarCoordinator: TabBarCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let cardRepository = CardRepositoryImpl(networkManager: networkManager)
        let cardUseCase = CardUseCase(repository: cardRepository)
        
        let reactor = HomeReactor(cardUseCase: cardUseCase)
        let homeViewController = HomeViewController(reactor: reactor)
        homeViewController.coordinator = self
        homeViewController.view.backgroundColor = TodotColors.Background.primary
        navigationController.navigationBar.isHidden = false
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func showDailyCard() {
        let reactor = DailyCardReactor()
        let dailyCardViewController = DailyCardViewController(reactor: reactor)
        dailyCardViewController.coordinator = self
        dailyCardViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardViewController, animated: true)
    }
    
    func showDailyCardDetail() {
        let dailyCardDetailViewController = DailyCardDetailViewController(cardType: .roleplay)
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: true)
    }
    
    func showBalanceCardDetail() {
        let dailyCardDetailViewController = DailyCardDetailViewController(cardType: .balance)
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: true)
    }
    
    func showHistoryCardDetail(card: QuestionCard) {
        let dailyCardDetailViewController = HistoryCardDetailViewController(card: card)
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: true)
    }
    
    func navigateToHome() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
