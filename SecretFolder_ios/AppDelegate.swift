//
//  AppDelegate.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import iRate
import Toast_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DBManager.shared.createDatabase()
        window?.rootViewController = RootTabbarViewController.vc
        Fabric.with([Crashlytics.self])
        
        //config iRate
        iRate.sharedInstance().appStoreID = UInt(Constant.appID) //app store id
        iRate.sharedInstance().daysUntilPrompt = 2
        iRate.sharedInstance().usesUntilPrompt = 5
        iRate.sharedInstance().remindPeriod = 3
        
        //Toast config
        ToastManager.shared.isQueueEnabled = true
        ToastManager.shared.style.activitySize = CGSize(width: 70, height: 70)
        
        iRate.sharedInstance().cancelButtonLabel = "Cancel"
        iRate.sharedInstance().rateButtonLabel = "Rate"
        iRate.sharedInstance().remindButtonLabel = "Later"
        
        //set isUnlock to true for present unlock vc after
        UserDefaults.standard.set(true, forKey: String.kIsUnlock)
        
        CustomAdsService.initAd()
        
        AdsTimer.shared.startTimer()
        
        setupIAP()
        
        UserDefaults.standard.set(false, forKey: String.kInAppPurchaseProUpgrade)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if UserDefaults.standard.bool(forKey: String.kNotFirstTime) {   /* if have set pass first time already */
            presentUnlockView()
        }
        UserDefaults.standard.set(true, forKey: String.kIsTerminated)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /* when after app terminate and reopen + have set pass already */
        NotificationCenter.default.post(name: NotificationKey.showAdUnlock, object: nil)
        if UserDefaults.standard.bool(forKey: String.kIsTerminated) && UserDefaults.standard.bool(forKey: String.kNotFirstTime) {
            presentUnlockView()
            UserDefaults.standard.set(false, forKey: String.kIsTerminated)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.set(true, forKey: String.kIsTerminated)
    }
}

