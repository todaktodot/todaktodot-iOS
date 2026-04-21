//
//  Coordinator.swift
//  todaktodot
//
//  Created by daye on 12/18/25.
//

import UIKit
import NetworkKit

final class SigninCoordinator: Coordinator {
    var onNicknameUpdated: ((String) -> Void)?
    var onCoupleInfoUpdated: ((CoupleInfo) -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    private let container = AppDIContainer.shared
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let signinViewController = SigninViewController()
        signinViewController.coordinator = self
        signinViewController.reactor = container.makeSigninReactor()
        navigationController.setViewControllers([signinViewController], animated: true)
    }
    
    func showCoupleConnect() {
        let coupleConnectViewController = CoupleConnectViewController()
        coupleConnectViewController.coordinator = self
        coupleConnectViewController.reactor = container.makeCoupleReactor()
        navigationController.pushViewController(coupleConnectViewController, animated: true)
    }
    
    func showNickname(flowType: ConnectFlowType? = nil, nickname: String? = nil) {
        let nicknameViewController = NicknameViewController(flowType: flowType, nickname: nickname)
        nicknameViewController.coordinator = self
        nicknameViewController.reactor = container.makeCoupleReactor()
        if flowType == nil {
            navigationController.setViewControllers([nicknameViewController], animated: true)
        } else {
            navigationController.pushViewController(nicknameViewController, animated: true)
        }
    }
    
    func showCoupleInfo(flowType: CoupleInfoFlowType = .newUser, info: CoupleInfo? = nil) {
        let coupleInfoViewController = CoupleInfoViewController(flowType: flowType, info: info)
        coupleInfoViewController.coordinator = self
        coupleInfoViewController.reactor = container.makeCoupleReactor()
        navigationController.pushViewController(coupleInfoViewController, animated: true)
    }
    
    func showTermsModal() {
        let termsModalViewController = TermsModalViewController()
        termsModalViewController.reactor = container.makeCoupleReactor()
        termsModalViewController.modalPresentationStyle = .overFullScreen
        termsModalViewController.modalTransitionStyle = .crossDissolve
        navigationController.present(termsModalViewController, animated: true, completion: nil)
    }
    
    func dismissModal() {
        navigationController.dismiss(animated: true)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func navigateToMain() {
        if let coordinator = parentCoordinator as? AppCoordinator {
            coordinator.showMainFlow()
        }
        if let coordinator = parentCoordinator as? TabBarCoordinator {
            coordinator.start()
        }
        UserdefaultKey.isLoggedIn = true
    }
}
