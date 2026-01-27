//
//  Coordinator.swift
//  todaktodot
//
//  Created by daye on 12/18/25.
//

import UIKit

final class SigninCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = true
    }
    
    func start() {
        let signinViewController = SigninViewController()
        signinViewController.coordinator = self
        signinViewController.reactor = SigninReactor()
        navigationController.setViewControllers([signinViewController], animated: true)
    }
    
    func showCoupleConnect() {
        let coupleConnectViewController = CoupleConnectViewController(code: ["A", "A", "A", "A", "A"], flowType: .create)
        coupleConnectViewController.coordinator = self
        navigationController.pushViewController(coupleConnectViewController, animated: true)
    }
    
    func showCoupleConnectOnly() {
        let coupleConnectViewController = CoupleConnectViewController(code: ["A", "A", "A", "A", "A"], flowType: .join)
        coupleConnectViewController.coordinator = self
        navigationController.setViewControllers([coupleConnectViewController], animated: true)
    }
    
    func showNickname(flowType: ConnectFlowType) {
        let nicknameViewController = NicknameViewController(flowType: flowType)
        nicknameViewController.coordinator = self
        navigationController.pushViewController(nicknameViewController, animated: true)
    }
    
    func showCoupleInfo(flowType: CoupleInfoFlowType = .newUser) {
        let coupleInfoViewController = CoupleInfoViewController(flowType: flowType)
        coupleInfoViewController.coordinator = self
        navigationController.pushViewController(coupleInfoViewController, animated: true)
    }
    
    func showTermsModal() {
        let termsModalViewController = TermsModalViewController()
        termsModalViewController.modalPresentationStyle = .overFullScreen
        termsModalViewController.modalTransitionStyle = .crossDissolve
        navigationController.topViewController?.present(termsModalViewController, animated: true, completion: nil)
    }
    
    func dismissModal() {
        navigationController.dismiss(animated: true)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
    
    func navigateToMain() {
        parentCoordinator?.showMainFlow()
    }
    
    func goMainFlow() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        addChild(tabBarCoordinator)
        tabBarCoordinator.start()
    }
}
