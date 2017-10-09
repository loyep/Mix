//
//  AppDelegate.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyWeibo
import SwiftTheme

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds) {
        didSet {
            window?.backgroundColor = UIColor.white
        }
    }
    
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
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
}

extension AppDelegate: WeiboSDKDelegate {
    
    // MARK: 设置微博的app配置
    fileprivate func setupSinaWeiboConfig() -> () {
        #if DEBUG
            WeiboSDK.enableDebugMode(true)
        #endif
        WeiboSDK.registerApp("1522592428")
    }
    
    func didReceiveWeiboResponse(_ wbResponse: WBBaseResponse!) {
        guard let response = wbResponse.userInfo as? [String: Any], let accessToken = response["access_token"] as? String else {
            return
        }
        
        guard let token = SwiftyWeibo.Token(
            parameters: ["clientID": weibo.clientID,
                         "clientSecret": weibo.clientSecret,
                         "expiresAt": Date(timeIntervalSinceNow: (response["expires_in"] as! NSString).doubleValue as TimeInterval),
                         "accessToken": accessToken]) else {
                            return
        }
        weibo.token = token
        weibo.tokenStore.set(token, forProvider: weibo)
        let tokenPlugin = AccessTokenPlugin(tokenClosure: accessToken)
        weibo.plugins.updateValue(tokenPlugin, forKey: tokenPlugin.pluginIdentifier)
        //        UIApplication.shared.keyWindow?.rootViewController = NavigationController(rootViewController: TabBarController())
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WelcomeViewController.weiboLoginSuccessNotice), object: nil, userInfo: nil)
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
        let bundleShortVersion = Bundle.releaseVersionNumber!
        let bundleIdentifier = Bundle.bundleIdentifier!
        
        guard let realm = try? Realm(dbName: .public) else { return false }
        
        guard
            let config = realm.object(ofType: Config.self, forPrimaryKey: bundleIdentifier),
            config.lastLoginVersion >= bundleShortVersion
            else
        {
            try? realm.write {
                let config = Config()
                config.bundleIdentifier = bundleIdentifier
                config.lastLoginVersion = bundleShortVersion
                realm.add(config, update: true)
            }
            rootViewController = FeatureViewController()
            return true
        }
        
        guard weibo.token != nil else {
            rootViewController = WelcomeViewController()
            return true
        }
        
        rootViewController = Storyboard.main.scene()
        return true
    }
    
}

