//
//  Config.swift
//  Mix
//
//  Created by Maxwell on 25/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SwiftyWeibo

let bundleShortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let bundleIdentifier = Bundle.main.bundleIdentifier!

final public class Config: Object {
    
    public static let appGroupID: String = "group.Maxsey.Mix"
    
    @objc override public class func primaryKey() -> String? {
        return "bundleIdentifier"
    }
    
    dynamic var lastLoginVersion: String = "0.0.0"
    
    dynamic var bundleIdentifier: String = ""
    
    dynamic var token: NSData? = nil
    
}

class OAuthToken: Object {
    
    @objc override public class func primaryKey() -> String? {
        return "clientID"
    }
    
    dynamic var clientID: String = ""
    
    dynamic var clientSecret: String? = nil
    
    dynamic var code: String? = nil
    
    dynamic var expiresAt: NSDate? = nil
    
    dynamic var accessToken: String? = nil
    
    fileprivate var parameters: SwiftyWeibo.Token.Parameters {
        var params: [String: Any] = [
            "clientID": clientID,
            "clientSecret": clientSecret ?? "",
            "expiresAt": expiresAt ?? NSDate() as Date,
            "accessToken": accessToken ?? ""
        ]
        if let code = self.code {
            params["code"] = code
        }
        return params
    }
    
    fileprivate func token() -> Token? {
        return Token(parameters: parameters)
    }
}

extension Realm: TokenStore {
    
    fileprivate func key(forProvider provider: SwiftyWeibo.Provider) -> String {
        return provider.clientID
    }
    
    public func token(forProvider provider: SwiftyWeibo.Provider) -> SwiftyWeibo.Token? {
        let key = self.key(forProvider: provider)
        guard let realm = try? Realm(), let token: OAuthToken = realm.object(ofType: OAuthToken.self, forPrimaryKey: key) else {
            return nil
        }
        
        return token.token()
    }
    
    public func set(_ token: SwiftyWeibo.Token?, forProvider provider: SwiftyWeibo.Provider) {
        let key = self.key(forProvider: provider)
        guard let realm = try? Realm() else {
            return
        }
        
        try? realm.write {
            if let token = token {
                realm.create(OAuthToken.self, value: token.parameters, update: true)
            } else {
                if let token = realm.object(ofType: OAuthToken.self, forPrimaryKey: key) {
                    realm.delete(token)
                }
            }
        }
    }
    
}
