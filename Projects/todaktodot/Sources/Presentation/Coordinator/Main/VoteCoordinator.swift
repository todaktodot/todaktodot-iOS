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
        let vc = MakeVoteViewController()
        vc.coordinator = self
        vc.reactor = MakeVoteReactor(mode: .create, useCase: container.makeVoteUseCase())
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        navigationController.present(nav, animated: true)
    }
    
    // TODO: 나중에 데이터 넘기는걸로 변경
    func showEditVote(voteId: String) {
        let vc = MakeVoteViewController()
        vc.coordinator = self
        vc.reactor = MakeVoteReactor(mode: .edit(voteId: voteId), useCase: container.makeVoteUseCase())
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        navigationController.present(nav, animated: true)
    }
    
    func showModal(type: ModalType) {
        let viewController: UIViewController

        switch type {
        case .filter:
            let vc = VoteFilterModalViewController()
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
    
    func dismissModal(topic: CardSubject? = nil, isClosed: Bool? = nil, onlyMine: Bool = false) {
        navigationController.dismiss(animated: true)
    }
}
