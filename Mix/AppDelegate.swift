//
//  AppDelegate.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? =  {
        var appWindow = UIWindow(frame: UIScreen.main.bounds)
        return appWindow
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupConfigurations()
        return setupAppRoot()
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
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

extension AppDelegate: WeiboSDKDelegate {
    
    // MARK: 设置微博的app配置
    fileprivate func setupSinaWeiboConfig() -> () {
        #if DEBUG
            WeiboSDK.enableDebugMode(true)
        #endif
        WeiboSDK.registerApp("1522592428")
        
        Realm.Configuration.defaultConfiguration = realmConfig()
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        print(response.userInfo)
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        print(request)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WeiboSDK.handleOpen(url, delegate: self)
    }
    
}

extension AppDelegate {
    
    /// 进行App的配置
    fileprivate func setupConfigurations() -> () {
        setupSinaWeiboConfig()
    }
    
    fileprivate func setupAppRoot() -> Bool {
        window?.backgroundColor = UIColor.white
        guard let realm = try? Realm() else {
            return false
        }
        
        let bundleShortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let bundleIdentifier = Bundle.main.bundleIdentifier!
//        try? realm.write {
//            realm.deleteAll()
//        }
        if realm.objects(Config.self).count == 0 {
            try! realm.write {
                realm.create(Config.self)
            }
        }
        
        let config: Config = realm.object(ofType: Config.self, forPrimaryKey: bundleIdentifier)!
        guard config.lastLoginVersion! >= bundleShortVersion else {
            try? realm.write {
                config.lastLoginVersion = bundleShortVersion
            }
            let navigationController = NavigationController(rootViewController: WelcomeViewController())
            navigationController.isNavigationBarHidden = true
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
            return true
        }
        
        let navigationController = NavigationController(rootViewController: TabBarController())
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
}

