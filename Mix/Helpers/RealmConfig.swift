//
//  RealmConfig.swift
//  Mix
//
//  Created by Maxwell on 25/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import RealmSwift

public func realmConfig() -> Realm.Configuration {
    // 默认将 Realm 放在 App Group 里
    let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Config.appGroupID)!
    let realmFileURL = directory.appendingPathComponent("db.realm")
    
    #if DEBUG
        print("Realm DB Path: \(realmFileURL)")
    #endif
    var config = Realm.Configuration()
    config.fileURL = realmFileURL
    config.schemaVersion = 5
    config.migrationBlock = { migration, oldSchemaVersion in
        
    }
    
    return config
}

