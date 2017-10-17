//
//  Provider+OAuth.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import Result

public let SwiftyWeiboRedirectURL = "https://api.weibo.com/oauth2/default.html"

// MARK: callback notification

struct CallbackNotification {
    @available(*, deprecated: 0.5, message: "Use Notification.Name.OAuthHandleCallbackURL")
    static let notificationName = Notification.Name(rawValue: "SwiftyWeiboCallbackNotificationName")
    static let optionsURLKey = "SwiftyWeiboCallbackNotificationOptionsURLKey"
}

extension Provider {
    
    /// Handle callback url which contains now token information
    public static func handle(url: URL) {
        let notification = Notification(name: NSNotification.Name.SwiftyWeiboHandleCallbackURL, object: nil,
                                        userInfo: [CallbackNotification.optionsURLKey: url])
        notificationCenter.post(notification)
    }
    
    func observeCallback(_ block: @escaping (_ url: URL) -> Void) {
        self.observer = Provider.notificationCenter.addObserver(forName: NSNotification.Name.SwiftyWeiboHandleCallbackURL, object: nil, queue: OperationQueue.main) { [weak self] notification in
            self?.removeCallbackNotificationObserver()
            
            if let urlFromUserInfo = notification.userInfo?[CallbackNotification.optionsURLKey] as? URL {
                block(urlFromUserInfo)
            } else {
                // Internal error
                assertionFailure()
            }
        }
    }
    
    /// Remove internal observer on authentification
    public func removeCallbackNotificationObserver() {
        if let observer = self.observer {
            Provider.notificationCenter.removeObserver(observer)
        }
    }
    
    /// Function to call when web view is dismissed without authentification
    public func cancel() {
        self.removeCallbackNotificationObserver()
    }
    
    /// Generate state code
    public static func generateState(withLength len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = UInt32(letters.characters.count)
        
        var randomString = ""
        for _ in 0..<len {
            let rand = arc4random_uniform(length)
            let idx = letters.index(letters.startIndex, offsetBy: Int(rand))
            let letter = letters.characters[idx]
            randomString += String(letter)
        }
        return randomString
    }
    
    public func authorize(scope: [String] = ["all"], state: String = Provider.generateState(withLength: 20), completion: @escaping (_ result: Result<Token, SwiftyWeiboError>) -> Void) -> () {
        guard let urlRequest = endpoint(SwiftyWeibo.OAuth2.authorize(config: self, scopes: scope, state: state)).urlRequest,
            let queryURL = urlRequest.url else {
                return
        }
        
        self.observeCallback { [weak self] url in
            var queries = url.queries
            guard let `self` = self, let code = queries["code"] else {
                //                                OAuth.retainError(failure);
                return
            }
            let _ = self.accessToken(byCode: code, completion: { [weak self] result in
                guard let `self` = self else {
                    return
                }
                
                do {
                    let response = try result.dematerialize().mapJSON() as! [String: Any]
                    guard let accessToken = response["access_token"] as? String else {
                        return
                    }
                    
                    guard let token = Token(
                        parameters: ["clientID": self.clientID,
                                     "clientSecret": self.clientSecret,
                                     "expiresAt": Date(timeIntervalSinceNow: response["expires_in"] as! TimeInterval),
                                     "accessToken": accessToken,
                                     "code": code]) else {
                                        return
                    }
                    self.token = token
                    self.tokenStore.set(token, forProvider: self)
                    let tokenPlugin = AccessTokenPlugin(tokenClosure: accessToken)
                    self.plugins.updateValue(tokenPlugin, forKey: tokenPlugin.pluginIdentifier)
                    completion(.success(token))
                } catch {
                    let error = SwiftyWeiboError.missingToken
                    completion(.failure(error))
                }
            })
        }
        
        let web = WebViewController()
        web.handle(queryURL, redirectURL)
    }
    
    func accessToken(byCode code: String, completion: @escaping Completion) -> Cancellable {
        return self.request(SwiftyWeibo.OAuth2.accessToken(self, code: code), completion: completion)
    }
    
}

public extension Notification.Name {
    public static let SwiftyWeiboHandleCallbackURL: Notification.Name = .init("SwiftyWeiboCallbackNotificationName")
}
