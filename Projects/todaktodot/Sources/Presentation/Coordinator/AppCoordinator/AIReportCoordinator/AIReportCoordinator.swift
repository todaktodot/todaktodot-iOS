//
//  AIReportCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 1/20/26.
//

import UIKit

final class AIReportCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = AIReportViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showLoading() {
        let vc = AIReportLoadingViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showNext(step: AIReportViewStep, animated: Bool = true) {
        let vc = AIReportDetailViewController(step: step)
        vc.hidesBottomBarWhenPushed = true
        vc.coordinator = self

        var vcs = self.navigationController.viewControllers
        vcs.removeAll { $0 is AIReportLoadingViewController }
        vcs.append(vc)

        self.navigationController.setViewControllers(vcs, animated: animated)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func navigateRoot() {
        navigationController.popToRootViewController(animated: true)
    }
}
