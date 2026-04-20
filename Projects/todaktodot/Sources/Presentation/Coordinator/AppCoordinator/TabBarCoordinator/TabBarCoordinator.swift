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
    private let cardUseCase: CardUseCase
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var tabBarCoordinator: TabBarCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let cardRepository = CardRepositoryImpl(networkManager: networkManager)
        self.cardUseCase = CardUseCase(repository: cardRepository)
    }
    
    func start() {
        let authRepository = AuthRepositoryImpl(
            kakaoAuthProvider: KakaoAuthProvider(),
            googleAuthProvider: GoogleAuthProvider(),
            appleAuthProvider: AppleAuthProvider(),
            networkManager: networkManager
        )
        let loginUseCase = LoginUseCase(repository: authRepository)
        let reactor = HomeReactor(cardUseCase: cardUseCase, loginUseCase: loginUseCase)
        let homeViewController = HomeViewController(reactor: reactor)
        homeViewController.coordinator = self
        homeViewController.view.backgroundColor = TodotColors.Background.primary
        navigationController.navigationBar.isHidden = false
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func showDailyCard(todayCards: [QuestionCard], selectedType: CardType) {
        let reactor = DailyCardReactor(cardUseCase: cardUseCase, dailyCards: todayCards, selectedType: selectedType)
        let dailyCardViewController = DailyCardViewController(reactor: reactor)
        dailyCardViewController.coordinator = self
        dailyCardViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardViewController, animated: true)
    }
    
    func showDailyCardDetail(card: QuestionCard) {
        let reactor = DailyCardReactor(cardUseCase: cardUseCase, dailyCards: [card], selectedType: .none)
        let dailyCardDetailViewController = DailyCardDetailViewController(card: card, reactor: reactor)
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: true)
    }
    
    func showBalanceCardDetail(card: QuestionCard) {
        let reactor = DailyCardReactor(cardUseCase: cardUseCase, dailyCards: [card], selectedType: .none)
        let dailyCardDetailViewController = DailyCardDetailViewController(card: card, reactor: reactor)
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: true)
    }
    
    func showHistoryCardDetail(card: QuestionCard, animated: Bool = true) {
        let reactor = HistoryCardDetailReactor(cardUseCase: cardUseCase, card: card)
        let dailyCardDetailViewController = HistoryCardDetailViewController(card: card)
        dailyCardDetailViewController.reactor = reactor
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: animated)
    }
    
    func navigateToHome() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
