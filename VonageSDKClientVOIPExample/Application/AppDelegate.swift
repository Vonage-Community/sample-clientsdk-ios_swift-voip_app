//
//  AppDelegate.swift
//  VonageSDKClientVOIPExample
//
//  Created by Ashley Arthur on 25/01/2023.
//

import UIKit
import VonageClientSDKVoice
import CallKit
import Combine

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var callController: CallController!
    var pushController: PushController!
    var userController: UserController!
    private var cancellables = Set<AnyCancellable>()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Create Application Object Graph
        let vonageClient = VGVoiceClient()
        vonageClient.setConfig(.init(region: .US))
        VGBaseClient.setDefaultLoggingLevel(.debug)
        
        callController = VonageCallController(client: vonageClient)
        pushController = PushController()
        userController = UserController()
        
        // Bind Non UI related Subscribers
        // Its important todo this here so we can respond to push notifications
        // received when app has been terminated
        bind()
        
        // Application onboarding
        let mediaType = AVMediaType.audio
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                print("🎤 access \(granted ? "granted" : "denied")")
            }
        case .authorized, .denied, .restricted:
            print("auth")
        }

        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)        
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: Notifications
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: NSNotification.didRegisterForRemoteNotificationNotification, object: nil, userInfo: ["data":deviceToken])
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NotificationCenter.default.post(name: NSNotification.didFailToRegisterForRemoteNotification, object: nil, userInfo: ["error":error])
    }
}


extension NSNotification {
    public static let didRegisterForRemoteNotificationNotification = NSNotification.Name("didRegisterForRemoteNotificationWithDeviceTokenNotification")
    public static let didFailToRegisterForRemoteNotification = NSNotification.Name("didFailToRegisterForRemoteNotificationsWithErrorNotification")

}


extension AppDelegate {
    
    func bind() {
        self.pushController.initialisePushTokens()

        pushController.voipPush.sink {
            self.callController.reportVoipPush($0)
        }
        .store(in: &cancellables)
        

        
        // On user login OR user restore, provide vonage sdk with required service token
        // And setup push
        userController.user
            .replaceError(with: nil)
            .compactMap { $0 }
            .sink { (user) in
                self.callController.updateSessionToken(user.1)
            }
            .store(in: &cancellables)
        
        userController.restoreUser()
        
        // Once the device has registered for push AND we have a logged in user
        // register device with vonage
        pushController.pushKitToken
            .combineLatest(pushController.notificationToken)
            .filter { (t1,t2) in t1 != nil && t2 != nil }
            .sink { token in
                self.callController.registerPushTokens((user:token.1!,voip:token.0!))
            }
            .store(in: &cancellables)
    }
}
