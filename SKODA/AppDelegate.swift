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
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var content:JSON!
    
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
        if #available(iOS 10, *) {
            
            //Notifications get posted to the function (delegate):  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void)"
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                
                guard error == nil else {
                    //Display Error.. Handle Error.. etc..
                    return
                }
                
                if granted {
                    //Do stuff here..
                }
                else {
                    //Handle user denying permissions..
                }
            }
            
        } else {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            
        }
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }
    
    @objc func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            if GlobalVar.user_id != "0" {
                registerDevice(deviceToken: refreshedToken)
            }
        }
    }
    
    // Device Token取得
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        if let refreshedToken = InstanceID.instanceID().token() {
            print("google token: \(refreshedToken)")
            if GlobalVar.user_id != "0" {
                registerDevice(deviceToken: refreshedToken)
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

