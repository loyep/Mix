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
        appWindow.backgroundColor = UIColor.white
        return appWindow
    }()
    
    var rootViewController: UIViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupConfigurations()
        
        guard setupAppRoot() else {
            return false
        }
        
        let navigationController = NavigationController(rootViewController: rootViewController)
        navigationController.isNavigationBarHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
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
        guard let realm = try? Realm() else {
            return false
        }
        
        let bundleShortVersion = Bundle.releaseVersionNumber!
        let bundleIdentifier = Bundle.bundleIdentifier
        
        if realm.object(ofType: Config.self, forPrimaryKey: bundleIdentifier) == nil {
            try? realm.write {
                realm.create(Config.self, value: ["bundleIdentifier": bundleIdentifier], update: false)
            }
        }
        
        let config: Config = realm.object(ofType: Config.self, forPrimaryKey: bundleIdentifier)!
        guard config.lastLoginVersion >= bundleShortVersion else {
            try? realm.write {
                config.lastLoginVersion = bundleShortVersion
            }
            rootViewController = FeatureViewController()
            return true
        }
        
        guard weibo.token != nil else {
            rootViewController = WelcomeViewController()
            return true
        }
        
        rootViewController = TabBarController()
        return true
    }
    
}

