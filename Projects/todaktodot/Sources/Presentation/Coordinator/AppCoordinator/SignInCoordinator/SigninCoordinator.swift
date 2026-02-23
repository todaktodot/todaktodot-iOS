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
    private let networkManager = NetworkManager.shared // TODO: AppDIContainer 사용? 고민
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let useCase = LoginUseCase(
            repository: AuthRepositoryImpl(
                kakaoAuthProvider: KakaoAuthProvider(),
                googleAuthProvider: GoogleAuthProvider(),
                appleAuthProvider: AppleAuthProvider(),
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
        let coupleConnectViewController = CoupleConnectViewController()
        coupleConnectViewController.coordinator = self
        coupleConnectViewController.reactor = CoupleReactor(coupleUseCase: useCase)
        navigationController.pushViewController(coupleConnectViewController, animated: true)
    }
    
    func showNickname(flowType: ConnectFlowType? = nil) {
        let useCase = CoupleUseCase(
            repository: CoupleRepositoryImpl(
                networkManager: networkManager
                )
        )
        let nicknameViewController = NicknameViewController(flowType: flowType)
        nicknameViewController.coordinator = self
        nicknameViewController.reactor = CoupleReactor(coupleUseCase: useCase)
        if flowType == nil {
            navigationController.setViewControllers([nicknameViewController], animated: true)
        } else {
            navigationController.pushViewController(nicknameViewController, animated: true)
        }
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
        UserdefaultKey.isLoggedIn = true
    }
}
