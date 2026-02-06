//
//  Coordinator.swift
//  todaktodot
//
//  Created by daye on 12/18/25.
//

import UIKit
import NetworkKit

final class SigninCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var parentCoordinator: Coordinator?
    weak var tabBarCoordinator: TabBarCoordinator?
    private let networkManager = NetworkManager() // TODO: AppDIContainer 사용? 고민
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let useCase = LoginUseCase(
            repository: AuthRepositoryImpl(
                kakaoAuthProvider: KakaoAuthProvider(),
                googleAuthProvider: GoogleAuthProvider(),
                networkManager: networkManager
            )
        )
        let signinViewController = SigninViewController()
        signinViewController.coordinator = self
        signinViewController.reactor = SigninReactor(loginUseCase: useCase)
        navigationController.setViewControllers([signinViewController], animated: true)
    }
    
    func showCoupleConnect() {
        let useCase = CoupleUseCase(
            repository: CoupleRepositoryImpl(
                networkManager: networkManager
                )
        )
        let coupleConnectViewController = CoupleConnectViewController(flowType: .create)
        coupleConnectViewController.coordinator = self
        coupleConnectViewController.reactor = CoupleReactor(coupleUseCase: useCase)
        navigationController.pushViewController(coupleConnectViewController, animated: true)
    }
    
    func showCoupleConnectOnly() {
        let coupleConnectViewController = CoupleConnectViewController(flowType: .join)
        coupleConnectViewController.coordinator = self
        navigationController.setViewControllers([coupleConnectViewController], animated: true)
    }
    
    func showNickname(flowType: ConnectFlowType) {
        let useCase = CoupleUseCase(
            repository: CoupleRepositoryImpl(
                networkManager: networkManager
                )
        )
        let nicknameViewController = NicknameViewController(flowType: flowType)
        nicknameViewController.coordinator = self
        nicknameViewController.reactor = CoupleReactor(coupleUseCase: useCase)
        self.navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(nicknameViewController, animated: true)
    }
    
    func showCoupleInfo(flowType: CoupleInfoFlowType = .newUser) {
        let useCase = CoupleUseCase(
            repository: CoupleRepositoryImpl(
                networkManager: networkManager
                )
        )
        let coupleInfoViewController = CoupleInfoViewController(flowType: flowType)
        coupleInfoViewController.coordinator = self
        coupleInfoViewController.reactor = CoupleReactor(coupleUseCase: useCase)
        self.navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(coupleInfoViewController, animated: true)
    }
    
    func showTermsModal() {
        let useCase = CoupleUseCase(
            repository: CoupleRepositoryImpl(
                networkManager: networkManager
                )
        )
        let termsModalViewController = TermsModalViewController()
        termsModalViewController.reactor = CoupleReactor(coupleUseCase: useCase)
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
    }
}
