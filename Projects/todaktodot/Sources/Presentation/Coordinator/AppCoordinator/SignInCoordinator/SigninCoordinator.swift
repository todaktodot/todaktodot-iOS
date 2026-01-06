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
    }
    
    func start() {
        let signinViewController = SigninViewController()
        navigationController.setViewControllers([signinViewController], animated: false)
    }
    
    func showNickname() {
        let nicknameViewController = NicknameViewController()
        navigationController.pushViewController(nicknameViewController, animated: true)
    }
    
    func showCoupleInfo() {
        let coupleInfoViewController = CoupleInfoViewController()
        navigationController.pushViewController(coupleInfoViewController, animated: true)
    }
    
    func showCoupleConnect() {
        let coupleConnectViewController = CoupleConnectViewController()
        navigationController.pushViewController(coupleConnectViewController, animated: true)
    }
    
    func showTermsModal() {
        let termsModalViewController = TermsModalViewController()
        termsModalViewController.modalPresentationStyle = .pageSheet
        navigationController.present(termsModalViewController, animated: true)
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
}
