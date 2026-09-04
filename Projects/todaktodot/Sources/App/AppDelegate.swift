import UIKit
import RxKakaoSDKCommon
import FirebaseCore
import GoogleSignIn
import FirebaseMessaging
import NetworkKit
import PinLayout

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        NetworkManager.setup(tokenProvider: AppTokenProvider())
        
        FirebaseApp.configure()
        
        let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOption,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        if let APIKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String {
            RxKakaoSDK.initSDK(appKey: APIKey)
        }
        
        if let clientID = FirebaseApp.app()?.options.clientID {
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
        }
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let _ = error {
                return
            }
            
            if let _ = user {
            } else {
            }
        }
        NSTimeZone.default = TimeZone(identifier: "Asia/Seoul")!
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showPendingVoteHiddenAlert),
            name: .sceneWillEnterForeground,
            object: nil
        )
        
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "None")")
        UserdefaultKey.diviceToken = fcmToken
    }
}

private enum AssociatedKeys {
    static var pushUserInfo = "pushUserInfo"
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token (Hex): \(tokenString)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("📩 Silent Push Received")
        print("userInfo:", userInfo)
        
        if let type = userInfo["type"] as? String {
            if type == "CONNECT_COUPLE" {
                NotificationCenter.default.post(name: .connectionCompleteAndGoToNickname, object: nil)
            } else if type == "DISCONNECT_COUPLE" {
                NotificationCenter.default.post(name: .coupleDisconnected, object: nil)
            } else if type == "VOTE_HIDDEN" {
                if application.applicationState == .active {
                    DispatchQueue.main.async {
                        self.showVoteHiddenAlert(isSendAdmin: true)
                    }
                } else {
                    UserdefaultKey.pendingVoteHiddenAlertAdmin = true
                }
            } else if type == "VOTE_HIDDEN_BY_REPORT" {
                if application.applicationState == .active {
                    DispatchQueue.main.async {
                        self.showVoteHiddenAlert(isSendAdmin: false)
                    }
                } else {
                    UserdefaultKey.pendingVoteHiddenAlertUser = true
                }
            }
        }
        
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
        
        let title = notification.request.content.title
        let body = notification.request.content.body
        
        if title.contains("연결되었어요!") {
           NotificationCenter.default.post(name: .connectionCompleteAndGoToNickname, object: nil)
        } else {
            let userInfo = notification.request.content.userInfo
            let pushType = userInfo["type"] as? String
            
            if pushType == "EMOJI_REACTION" {
                NotificationCenter.default.post(name: .partnerEmojiReceived, object: nil)
            } else if pushType == "PARTNER_ANSWER" || pushType == "BOTH_ANSWER" {
                NotificationCenter.default.post(name: .cardAnswerStatusChanged, object: nil)
            }
            
            DispatchQueue.main.async {
                self.showCustomInAppPush(title: title, body: body, userInfo: userInfo)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let title = response.notification.request.content.title
        
        if title.contains("질문이") {
            AnalyticsService.log(.pushOpen(type: .todayCardArrived))
        } else if title.contains("콕") {
            AnalyticsService.log(.pushOpen(type: .nudge))
        } else if title.contains("방금") {
            AnalyticsService.log(.pushOpen(type: .partnerCompleted))
        } else if title.contains("모두") {
            AnalyticsService.log(.pushOpen(type: .bothCompleted))
        } else if title.contains("연결되었어요!") {
            NotificationCenter.default.post(name: .connectionCompleteAndGoToNickname, object: nil)
        }
        
        PushRouter.shared.route(userInfo: response.notification.request.content.userInfo)
        completionHandler()
    }
    
    private func showCustomInAppPush(title: String, body: String, userInfo: [AnyHashable: Any] = [:]) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene, let window = windowScene.keyWindow else {
            return
        }
        
        window.subviews.filter({ $0 is InAppNotificationView }).forEach({ $0.removeFromSuperview() })
        
        let pushView = InAppNotificationView(title: title, body: body)
        pushView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(inAppPushTapped))
        pushView.addGestureRecognizer(tap)
        objc_setAssociatedObject(pushView, &AssociatedKeys.pushUserInfo, userInfo, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        window.addSubview(pushView)
        window.bringSubviewToFront(pushView)
        
        pushView.pin
            .top(-100)
            .horizontally(20)
            .height(80)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            pushView.pin
                .top(window.pin.safeArea.top)
                .horizontally(20)
                .height(80)
        }) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                guard pushView.superview != nil else { return }
                UIView.animate(withDuration: 0.3) {
                    pushView.pin.top(-100)
                } completion: { _ in
                    pushView.removeFromSuperview()
                }
            }
        }
    }
    
    private func findTopViewController(
        from viewController: UIViewController
    ) -> UIViewController {
        
        if let presentedViewController = viewController.presentedViewController {
            return findTopViewController(
                from: presentedViewController
            )
        }
        
        if let navigationController = viewController as? UINavigationController {
            return findTopViewController(
                from: navigationController.visibleViewController ?? navigationController
            )
        }
        
        if let tabBarController = viewController as? UITabBarController {
            return findTopViewController(
                from: tabBarController.selectedViewController ?? tabBarController
            )
        }
        
        return viewController
    }
    
    private func showVoteHiddenAlert(isSendAdmin: Bool) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.keyWindow,
              let rootViewController = window.rootViewController else {
            return
        }
        
        let topViewController = findTopViewController(
            from: rootViewController
        )
        
        let title = isSendAdmin ? "작성하신 투표가 가려졌어요" : "신고에 의해 투표가 가려졌어요"
        let body = isSendAdmin ? "운영 정책 위반으로 인해 숨김 처리되었어요\nMY > 내가 작성한 투표에서 확인 가능해요" : "신고 접수로 작성 투표가 피드에서 가려졌어요\nMY > 내가 작성한 투표에서 확인 가능해요"
        
        topViewController.showAlert(
            icon: UIImage(resource: .warning),
            title: title,
            description: body,
            primaryButtonTitle: "확인",
            primaryButtonAction: {}
        )
    }
    
    @objc private func showPendingVoteHiddenAlert() {
        let admin = UserdefaultKey.pendingVoteHiddenAlertAdmin
        let user = UserdefaultKey.pendingVoteHiddenAlertUser
        guard user || admin else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if admin {
                UserdefaultKey.pendingVoteHiddenAlertAdmin = false
                self.showVoteHiddenAlert(isSendAdmin: true)
            }
            if user {
                UserdefaultKey.pendingVoteHiddenAlertUser = false
                self.showVoteHiddenAlert(isSendAdmin: false)
            }
        }
    }
    
    @objc private func inAppPushTapped(_ sender: UITapGestureRecognizer) {
        guard let pushView = sender.view,
              let userInfo = objc_getAssociatedObject(pushView, &AssociatedKeys.pushUserInfo) as? [AnyHashable: Any] else { return }
        UIView.animate(withDuration: 0.2, animations: {
            pushView.alpha = 0
            pushView.transform = CGAffineTransform(translationX: 0, y: -20)
        }) { _ in
            pushView.removeFromSuperview()
        }
        PushRouter.shared.route(userInfo: userInfo)
    }
}
