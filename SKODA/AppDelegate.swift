//
//  AppDelegate.swift
//  SKODA
//
//  Created by 孫 鈺驊 on 2017/9/28.
//  Copyright © 2017年 孫 鈺驊. All rights reserved.
//

import UIKit
import UserNotifications
import FBSDKCoreKit
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var content:JSON!
    let gcmMessageIDKey = "296461173132"
    
    func registerDevice(deviceToken: String) {
        let parameters = [
            "id": GlobalVar.user_id,
            "token": "\(deviceToken)"]
        
        print(parameters)
        Public.getRemoteData("\(GlobalVar.serverIp)api/v1/updateToken", parameters: parameters as [String : AnyObject]) { (response, error) in
            if error {
                let errorMsg = response["Msg"].string
                print(errorMsg!)
            } else {
                print(response)
            }
        }
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        let defaults = UserDefaults.standard
        let hasSetId = defaults.value(forKey: "id") as? String
        
        if hasSetId != nil {
            GlobalVar.user_id = hasSetId!
        } else {
            GlobalVar.user_id = "0"
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Push通知
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().delegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // [END register_for_notifications]
        FirebaseApp.configure()
        
        // [START add_token_refresh_observer]
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: NSNotification.Name.InstanceIDTokenRefresh,
                                               object: nil)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }
    
    @objc func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            GlobalVar.deviceToken = refreshedToken
            if GlobalVar.user_id != "0" {
                registerDevice(deviceToken: refreshedToken)
            }
        }
        connectToFcm()
    }
    
    func connectToFcm() {
        // Won't connect since there is no token
        guard InstanceID.instanceID().token() != nil else {
            return
        }
        
        // Disconnect previous FCM connection if it exists.
        Messaging.messaging().disconnect()
        
        Messaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error?.localizedDescription ?? "")")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    
    // Device Token取得
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("google token: \(refreshedToken)")
            GlobalVar.deviceToken = refreshedToken
            if GlobalVar.user_id != "0" {
                registerDevice(deviceToken: refreshedToken)
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("didReceive \(userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("didReceive2 \(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("didReceive3 \(userInfo)")
        
        // Change this to your preferred presentation option
        // 設置通知的選項
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("didReceive4 \(userInfo)")
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // Receive data message on iOS 10 devices while app is in the foreground.
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("remoteMessage \(remoteMessage.appData)")
    }
}


