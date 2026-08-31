//
//  VoteCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import UIKit
import NetworkKit

final class VoteCoordinator: Coordinator {
    
    enum ModalType {
        case filter, menu, report, complete
    }
    
    var onFilter: ((CardSubject?, Bool?, Bool?) -> Void)?
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
    
    func showModal(type: ModalType, topic: CardSubject? = nil, isClosed: Bool? = nil, isMine: Bool? = nil) {
        let viewController: UIViewController

        switch type {
        case .filter:
            let vc = VoteFilterModalViewController(category: topic, isClosed: isClosed, isMine: isMine)
            vc.coordinator = self
            vc.reactor = container.makeVoteReactor()
            viewController = vc

        case .menu:
            let vc = MenuModalViewController()
            vc.coordinator = self
            viewController = vc

        case .report:
            navigationController.dismiss(animated: true)
            let vc = ReportModalViewController()
            vc.coordinator = self
            viewController = vc
            
        case .complete:
            navigationController.dismiss(animated: true)
            let vc = ReportCompleteModalViewController()
            vc.coordinator = self
            viewController = vc
        }

        viewController.modalPresentationStyle = .overFullScreen
        viewController.modalTransitionStyle = .crossDissolve

        navigationController.present(viewController, animated: true)
    }
    
    func dismissModal(topic: CardSubject? = nil, isClosed: Bool? = nil, onlyMine: Bool = false, updateFilter: Bool = false) {
        if updateFilter {
            onFilter?(topic, isClosed, onlyMine)
        }
        navigationController.dismiss(animated: true)
    }
}
