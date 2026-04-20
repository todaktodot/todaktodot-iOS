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
        UpdateManager.shared.fetch {
            let checkUpdate = UpdateManager.shared.checkUpdate()
            let type = checkUpdate.type
            let url = checkUpdate.url
            
            switch type {
            case .force:
                self.showUpdate(url: url)
            case .optional, .none:
                if self.isLoggedIn() {
                    self.showMainFlow()
                } else {
                    self.showSigninFlow()
                }
            }
            self.navigationController.view.backgroundColor = .white
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
    
    private func showUpdate(url: URL?) {
        let forceUpdateViewController = ForceUpdateViewController(url: url)
        navigationController.setViewControllers([forceUpdateViewController], animated: true)
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
