//
//  Coordinator.swift
//  todaktodot
//
//  Created by daye on 12/18/25.
//

import UIKit
import RxSwift

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var disposeBag = DisposeBag()
    private var currentCoordinator: Coordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = true
        setupLogoutObserver()
    }
    
    func start() {
        if isLoggedIn() {
            showMainFlow()
        } else {
            showSigninFlow()
        }
    }
    
    private func isLoggedIn() -> Bool {
        return UserdefaultKey.isLoggedIn
    }
    
    func showSigninFlow() {
        removeCurrentCoordinator()
        
        let signinCoordinator = SigninCoordinator(navigationController: navigationController)
        signinCoordinator.parentCoordinator = self
        addChild(signinCoordinator)
        currentCoordinator = signinCoordinator
        signinCoordinator.start()
    }
    
    func showMainFlow() {
        removeCurrentCoordinator()
        
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        addChild(tabBarCoordinator)
        currentCoordinator = tabBarCoordinator
        tabBarCoordinator.start()
    }
    
    private func removeCurrentCoordinator() {
        if let current = currentCoordinator {
            removeChild(current)
            currentCoordinator = nil
        }
    }
    
    private func setupLogoutObserver() {
        NotificationCenter.default.rx.notification(.logoutRequired)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.forceLogout()
            })
            .disposed(by: disposeBag)
    }
    
    private func forceLogout() {
        UserdefaultKey.resetAuthUserDefaults()
        
        showSigninFlow()
        navigationController.viewControllers.first?.showAlert(icon: UIImage(resource: .warning), title: "로그인 정보가 만료되었습니다\n다시 로그인 해주세요", primaryButtonTitle: "확인", primaryButtonAction: {})
    }
}
