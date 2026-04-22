//
//  HomeCoordinator.swift
//  todaktodot
//
//  Created by daye on 4/21/26.
//

import UIKit
import RxSwift
import NetworkKit

final class HomeCoordinator: Coordinator {
    private let container = AppDIContainer.shared
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var tabBarCoordinator: TabBarCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeViewController = HomeViewController(reactor: container.makeHomeReactor())
        homeViewController.coordinator = self
        homeViewController.view.backgroundColor = TodotColors.Background.primary
        navigationController.navigationBar.isHidden = false
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func showDailyCard(todayCards: [QuestionCard], selectedType: CardType) {
        let dailyCardViewController = DailyCardViewController(reactor: container.makeDailyCardReactor(dailyCards: todayCards, selectedType: selectedType))
        dailyCardViewController.coordinator = self
        dailyCardViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardViewController, animated: true)
    }
    
    func showDailyCardDetail(card: QuestionCard) {
        let dailyCardDetailViewController = DailyCardDetailViewController(card: card, reactor: container.makeDailyCardReactor(dailyCards: [card], selectedType: .none))
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: true)
    }
    
    func showBalanceCardDetail(card: QuestionCard) {
        let dailyCardDetailViewController = DailyCardDetailViewController(card: card, reactor: container.makeDailyCardReactor(dailyCards: [card], selectedType: .none))
        dailyCardDetailViewController.coordinator = self
        dailyCardDetailViewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(dailyCardDetailViewController, animated: true)
    }
    
    func showHistoryCardDetail(card: QuestionCard, animated: Bool = true) {
        let dailyCardDetailViewController = HistoryCardDetailViewController(card: card)
        dailyCardDetailViewController.reactor = container.makeHistoryCardDetailReactor(card: card)
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
