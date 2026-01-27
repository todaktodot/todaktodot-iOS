//
//  MypageCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit

final class MypageCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MypageViewContorller()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSigninFlow() {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.appCoordinator?.showSigninFlow()
    }
    
    func showTerms() {
        let vc = TermsViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showDetailTerms() {
        let webVC = WebViewController(url: "https://silver-curve-9aa.notion.site/297562bcddbd8098844cf8c5c8c8e429")
        webVC.modalPresentationStyle = .formSheet
        navigationController.present(webVC, animated: true, completion: nil)
    }
    
    func showDetailPersonalTerms() {
        let webVC = WebViewController(url: "https://silver-curve-9aa.notion.site/297562bcddbd8018b6a8ffdd3480ab2e?pvs=74")
        webVC.modalPresentationStyle = .formSheet
        navigationController.present(webVC, animated: true, completion: nil)
    }
    
    func showNickname() {
        let signinCoordinator = SigninCoordinator(navigationController: navigationController)
        addChild(signinCoordinator)
        signinCoordinator.showNickname(flowType: .edit)
    }
    
    func showCoupleInfo() {
        let signinCoordinator = SigninCoordinator(navigationController: navigationController)
        addChild(signinCoordinator)
        signinCoordinator.showCoupleInfo(flowType: .editUser)
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
