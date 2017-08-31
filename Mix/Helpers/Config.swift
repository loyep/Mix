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

let bundleShortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let bundleIdentifier = Bundle.main.bundleIdentifier!

final public class Config: Object {
    
    public static let appGroupID: String = "group.Maxsey.Mix"
    
    @objc override public class func primaryKey() -> String? {
        return "bundleIdentifier"
    }
    
    dynamic var lastLoginVersion: String?
    
    dynamic var bundleIdentifier: String = bundleShortVersion
    
}
