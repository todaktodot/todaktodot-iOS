//
//  MypageCoordinator.swift
//  todaktodot
//
//  Created by 임대진 on 1/27/26.
//

import UIKit
import NetworkKit

final class MypageCoordinator: Coordinator {
    var onNicknameUpdated: ((String) -> Void)?
    var onCoupleInfoUpdated: ((CoupleInfo) -> Void)?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var tabBarCoordinator: TabBarCoordinator?
    private let networkManager = NetworkManager.shared
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let useCase = MypageUsecase(
            repository: MypageRepositoryImpl(
                networkManager: networkManager
                )
        )
        let vc = MypageViewController()
        vc.coordinator = self
        vc.reactor = MyPageReactor(mypageUsecase: useCase)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showSigninFlow() {
        tabBarCoordinator?.showSignin()
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
        signinCoordinator.parentCoordinator = tabBarCoordinator
        addChild(signinCoordinator)
        signinCoordinator.onNicknameUpdated = { [weak self] nickname in
            self?.onNicknameUpdated?(nickname)
        }
        signinCoordinator.showNickname(flowType: .edit)
    }
    
    func showCoupleInfo() {
        let signinCoordinator = SigninCoordinator(navigationController: navigationController)
        addChild(signinCoordinator)
        signinCoordinator.onCoupleInfoUpdated = { [weak self] info in
            self?.onCoupleInfoUpdated?(info)
        }
        signinCoordinator.showCoupleInfo(flowType: .editUser)
    }
    
    func showCoupleConnect() {
        let signinCoordinator = SigninCoordinator(navigationController: navigationController)
        signinCoordinator.parentCoordinator = tabBarCoordinator
        addChild(signinCoordinator)
        signinCoordinator.showCoupleConnect()
    }
    
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
