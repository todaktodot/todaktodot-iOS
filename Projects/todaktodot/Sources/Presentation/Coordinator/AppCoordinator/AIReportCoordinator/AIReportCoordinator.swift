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
        navigationController.pushViewController(vc, animated: true)
    }
    
    func shoHistoryCard() {
        let vc = UIViewController()
        vc.view.backgroundColor = .white
        vc.title = "히스토리 카드"
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func navigateRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
