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
        setupUpdateCheckObserver()
        setupConnectedCoupleObserver()
    }
    
    func start() {
        handleUpdate(
            onForce: { [weak self] url in
                self?.showForceUpdate(url: url)
            },
            onOptional: { [weak self] _ in
                self?.routeInitialFlow()
            },
            onNone: { [weak self] in
                self?.routeInitialFlow()
            }
        )
    }
    
    func restart(alertType: LogoutType) {
        routeInitialFlow()
        showLogoutAlert(type: alertType)
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
    
    private func routeInitialFlow() {
        if isLoggedIn() {
            showMainFlow()
        } else {
            showSigninFlow()
        }
        navigationController.view.backgroundColor = .white
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
    
    private func setupConnectedCoupleObserver() {
        NotificationCenter.default.rx.notification(.connectionCompleteAndGoToNickname)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                if let topVC = self?.navigationController.topViewController,
                   topVC is NicknameViewController || topVC is SigninViewController {
                    return
                }

                UserdefaultKey.nicknameIsEmpty = true
                self?.showConnectedCoupleAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func forceLogout() {
        UserdefaultKey.resetAuthUserDefaults()
        
        showSigninFlow()
        navigationController.viewControllers.first?.showAlert(icon: UIImage(resource: .warning), title: "로그인 정보가 만료되었습니다\n다시 로그인 해주세요", primaryButtonTitle: "확인", primaryButtonAction: {})
    }
    
    private func showConnectedCoupleAlert() {
        self.navigationController.showAlert(icon: UIImage(resource: .heart), title: "커플 연결 완료!", description: "이제 둘만의 대화를 시작할 수 있어요\n닉네임을 입력하러 가볼까요?", primaryButtonTitle: "확인", primaryButtonAction: { [weak self] in
            guard let self else { return }
            removeCurrentCoordinator()
            
            let signinCoordinator = SigninCoordinator(navigationController: navigationController)
            signinCoordinator.parentCoordinator = self
            addChild(signinCoordinator)
            currentCoordinator = signinCoordinator
            signinCoordinator.showNickname(flowType: .join)
        })
    }
    
    private func showLogoutAlert(type: LogoutType) {
        var title = ""
        
        switch type {
        case .logout:
            title = "정상적으로 로그아웃 되었어요"
        case .disconnect:
            title = "정상적으로 커플 연결이 해제됐어요\n다시 로그인이 필요해요"
        case .withdrawal:
            title = "정상적으로 탈퇴 되었어요"
        }
        
        self.navigationController.showAlert(icon: UIImage(resource: .check), title: title, primaryButtonTitle: "확인", primaryButtonAction: {})
    }
}

// MARK: 업데이트
extension AppCoordinator {
    private func setupUpdateCheckObserver() {
        NotificationCenter.default.rx.notification(.sceneWillEnterForeground)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                guard UserdefaultKey.isKakaoLoginInProgress == false else { return }
                self?.checkNewVersion()
            })
            .disposed(by: disposeBag)
    }
    
    private func handleUpdate(
        onForce: @escaping (URL?) -> Void,
        onOptional: @escaping (URL?) -> Void,
        onNone: @escaping () -> Void
    ) {
        UpdateManager.shared.fetch {
            let update = UpdateManager.shared.checkUpdate()
            
            switch update.type {
            case .force:
                onForce(update.url)
            case .optional:
                if let maintenanceInfo = UpdateManager.shared.checkMaintenanceInfo() {
                    self.showMaintenance(maintenanceInfo)
                } else {
                    onOptional(update.url)
                }
            case .none:
                if let maintenanceInfo = UpdateManager.shared.checkMaintenanceInfo() {
                    self.showMaintenance(maintenanceInfo)
                } else {
                    onNone()
                }
            }
        }
    }
    
    private func showMaintenance(_ maintenanceAlertInfo: MaintenanceAlertInfo) {
        let forceUpdateViewController = ForceDimViewController(maintenanceAlertInfo: maintenanceAlertInfo)
        navigationController.setViewControllers([forceUpdateViewController], animated: true)
    }
    
    private func showForceUpdate(url: URL?) {
        let forceUpdateViewController = ForceDimViewController(url: url)
        navigationController.setViewControllers([forceUpdateViewController], animated: true)
    }
    
    private func checkNewVersion() {
        let shouldShowUpdateAlert: Bool = {
            guard let date = UserdefaultKey.skipUpdateAlertToday else {
                return true
            }
            return !Calendar.current.isDateInToday(date)
        }()

        guard shouldShowUpdateAlert else { return }
        
        handleUpdate(
            onForce: { [weak self] url in
                self?.showForceUpdate(url: url)
            },
            onOptional: { [weak self] url in
                self?.navigationController.showAlert(icon: UIImage(resource: .bell), title: "새로운 버전이 출시됐어요!", description: "지금 업데이트하면 더욱 빠르고 편리하게\n서비스를 이용할 수 있어요", primaryButtonTitle: "업데이트 하기", primaryButtonAction: {
                    if let url {
                        UIApplication.shared.open(url)
                    }
                }, secondaryButtonTitle: "나중에 할게요", isUpdate: .optional)
            },
            onNone: {}
        )
    }
}
