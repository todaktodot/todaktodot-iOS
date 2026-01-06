//
//  Coordinator.swift
//  todaktodot
//
//  Created by daye on 12/18/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private var currentCoordinator: Coordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.navigationController.isNavigationBarHidden = true
    }
    
    // TODO: 고민
    func start() {
        if isLoggedIn() {
            showMainFlow()
        } else {
            showSigninFlow()
        }
    }
    
    // TODO: 실제 로그인 정보로 변경
    private func isLoggedIn() -> Bool {
//        return UserdefaultKey.isSiginedIn
        return true
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
}
