//
//  AIReportCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 1/20/26.
//

import UIKit
import NetworkKit

final class AIReportCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var tabBarCoordinator: TabBarCoordinator?
    private let reactor = AIReportReactor(useCase: AIReportUseCase(repository: AIReportRepositoryImpl(networkManager: NetworkManager.shared)))
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = AIReportViewController()
        vc.coordinator = self
        vc.reactor = reactor
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showDetail(step: AIReportViewStep, detail: AIReportDetail) {
        let vc = AIReportDetailViewController(step: step, detail: detail)
        vc.coordinator = self
        vc.reactor = reactor
        
        if step == .full {
            var vcs = navigationController.viewControllers
            vcs.removeAll(where: { $0 is AIReportDetailViewController })
            vcs.append(vc)
            navigationController.setViewControllers(vcs, animated: true)
        } else {
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
    func showHistoryCard(card: QuestionCard) {
        let coordinator = HomeCoordinator(navigationController: navigationController)
        addChild(coordinator)
        coordinator.showHistoryCardDetail(card: card)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
