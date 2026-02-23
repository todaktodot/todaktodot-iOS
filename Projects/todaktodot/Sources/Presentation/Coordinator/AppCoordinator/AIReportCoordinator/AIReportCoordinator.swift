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
    
    func showNext(step: AIReportViewStep) {
        let vc = AIReportDetailViewController(step: step)
        vc.coordinator = self
        vc.reactor = reactor
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showDetail() {
        let vc = AIReportDetailViewController(step: .full)
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func navigateRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
