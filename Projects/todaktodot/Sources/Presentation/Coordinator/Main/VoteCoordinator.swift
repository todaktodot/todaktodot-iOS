//
//  VoteCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 8/10/26.
//

import UIKit
import NetworkKit

final class VoteCoordinator: Coordinator {
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
}
