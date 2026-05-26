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
        return true
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token: \(fcmToken ?? "None")")
        UserdefaultKey.diviceToken = fcmToken
    }
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

        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound])
        
        let title = notification.request.content.title
        let body = notification.request.content.body
        
        print("📩 userInfo pretty:")
        if let data = try? JSONSerialization.data(withJSONObject: notification.request.content.userInfo,
                                                   options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        }
        
        if title.contains("연결되었어요!") {
           NotificationCenter.default.post(name: .connectionCompleteAndGoToNickname, object: nil)
        } else {
            DispatchQueue.main.async {
                self.showCustomInAppPush(title: title, body: body)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let title = response.notification.request.content.title
        let body = response.notification.request.content.body
        
        print("📩 userInfo pretty:")
        if let data = try? JSONSerialization.data(withJSONObject: response.notification.request.content.userInfo,
                                                   options: .prettyPrinted),
           let jsonString = String(data: data, encoding: .utf8) {
            print(jsonString)
        } else {
            print("userInfo:", response.notification.request.content.userInfo)
        }
        
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
        
        completionHandler()
    }
    
    private func showCustomInAppPush(title: String, body: String) {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene, let window = windowScene.keyWindow else {
            return
        }
        
        window.subviews.filter({ $0 is InAppNotificationView }).forEach({ $0.removeFromSuperview() })
        
        let pushView = InAppNotificationView(title: title, body: body)
        window.addSubview(pushView)
        
        pushView.pin
            .top(-100)
            .horizontally(20)
            .height(80)
        
        UIView.animate(withDuration: 0.3, delay: 0) { [weak self] in
            guard let self else { return }
            pushView.pin
                .top(window.pin.safeArea.top)
                .horizontally(20)
                .height(80)
        } completion: { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: 0.3, delay: 2.0) {
                pushView.pin.top(-100)
            } completion: { _ in
                pushView.removeFromSuperview()
            }
        }
    }
}
