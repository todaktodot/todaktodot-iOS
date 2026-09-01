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
        case filter
        case menu(vote: VoteInfo)
        case report
        case complete
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
    
    /// 투표 게시/수정 완료 시 호출 - 피드에 토스트 + 리스트 새로고침
    func didFinishMakeVote(message: String) {
        if let voteVC = navigationController.viewControllers
            .compactMap({ $0 as? VoteViewController })
            .last {
            voteVC.reloadAndToast(message: message)
        }
    }
    
    /// 투표 삭제 완료 시 호출 - 모달 닫고 피드에서 즉시 제거 + 토스트
    func didDeleteVote(voteId: Int) {
        navigationController.dismiss(animated: true)
        if let voteVC = navigationController.viewControllers
            .compactMap({ $0 as? VoteViewController })
            .last {
            voteVC.removeVoteAndToast(voteId: voteId, message: "투표가 삭제되었어요")
        }
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
    
    func showEditVote(vote: VoteInfo) {
        let vc = MakeVoteViewController()
        vc.coordinator = self
        vc.reactor = MakeVoteReactor(mode: .edit(vote: vote), useCase: container.makeVoteUseCase())
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        nav.modalPresentationStyle = .fullScreen
        navigationController.present(nav, animated: true)
    }
    
    func showModal(type: ModalType, topic: CardSubject? = nil, isClosed: Bool? = nil, isMine: Bool? = nil) {
        let viewController: UIViewController

        switch type {
        case .filter:
            let vc = VoteFilterModalViewController(category: topic, isClosed: isClosed, isMine: isMine)
            vc.coordinator = self
            vc.reactor = container.makeVoteReactor()
            viewController = vc

        case .menu(let vote):
            let vc = MenuModalViewController()
            vc.coordinator = self
            vc.reactor = MenuModalReactor(vote: vote, useCase: container.makeVoteUseCase())
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
