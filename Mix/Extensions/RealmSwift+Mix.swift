//
//  RealmSwift+Mix.swift
//  Mix
//
//  Created by Maxwell on 08/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import RealmSwift

extension RealmCollection {
    
    /// filter and return Array.Type
    func filterArr(
        _ isInclude: (Self.Iterator.Element) -> Bool)
        -> [Self.Iterator.Element]
    {
        
        var arr: [Self.Iterator.Element] = []
        forEach {
            if isInclude($0) { arr.append($0) }
        }
        return arr
    }
    
    
    /// transform to Array.Type
    func mapArr() -> [Self.Iterator.Element] {
        
        var arr: [Self.Iterator.Element] = []
        forEach { arr.append($0) }
        return arr
    }
    
    func mapArr<T>(_ transform: (Self.Iterator.Element) -> T?) -> [T] {
        
        var arr: [T] = []
        
        forEach {
            
            transform($0).flatMap { arr.append($0) }
        }
        
        
        return arr
    }
}

extension Array {
    
    /// transform Array.Type to List.Type
    func mapList<T>(_ transform: (Element) -> T?) -> List<T> {
        
        let list = List<T>()
        forEach {
            
            transform($0).flatMap { list.append($0) }
        }
        return list
    }
}


extension Realm {
    
    /// initializer
    ///
    /// - Parameter dbName: Realm.DBName
    convenience init(dbName: Realm.DBName) throws {
        do {
            Realm.Configuration.defaultConfiguration = Realm.Configuration().config(with: dbName)
            try self.init()
        } catch let error {
            throw error
        }
    }
    
    struct DBName {
        
        var rawValue: String
        
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        static var user: Realm.DBName {
            // TODO: WaitUserName
            return  Realm.DBName("userName")
        }
        static let `public` = Realm.DBName("public")
    }
    
    static func write(for db: Realm.DBName = .user, task: () -> Void) {
        let realm = try? Realm(dbName: db)
        try? realm?.write {
            task()
        }
    }
    
    @discardableResult
    static func update<T: RealmSwift.Object, K>(
        _ type: T.Type,
        for db: Realm.DBName = .user,
        of primaryKey: K,
        task: (T) -> Void)
        -> T?
    {
        
        let realm = try? Realm(dbName: db)
        let objc = realm?.object(ofType: type, forPrimaryKey: primaryKey)
        
        if let objc = objc {
            try? realm?.write {
                task(objc)
            }
            return objc
        }
        return nil
    }
    
    @discardableResult
    static func update<T: RealmSwift.Object>(
        _ type: T.Type,
        for db: Realm.DBName = .user,
        task: (T) -> Void) -> [T]?
    {
        let realm = try? Realm(dbName: db)
        let s = realm?.objects(type)
        
        try? realm?.write {
            s?.forEach(task)
        }
        return s?.mapArr()
    }
    
    static func add(
        _ objc: RealmSwift.Object,
        for db: Realm.DBName = .user,
        update: Bool = true)
    {
        let realm = try? Realm(dbName: db)
        try? realm?.write {
            realm?.add(objc, update: update)
        }
    }
    
    static func add<S: Sequence>(
        _ objcs: S,
        for db: Realm.DBName = .user,
        update: Bool = true)
        where S.Iterator.Element: RealmSwift.Object
    {
        
        let realm = try? Realm(dbName: db)
        
        try? realm?.write {
            realm?.add(objcs, update: update)
        }
    }
    
    static func objcs<T: RealmSwift.Object>(
        _ type: T.Type,
        for db: Realm.DBName = .user)
        -> RealmSwift.Results<T>?
    {
        return try? Realm(dbName: db).objects(type)
    }
    
    static func objc<T: RealmSwift.Object, K>(
        _ type: T.Type,
        for db: Realm.DBName = .user,
        of primaryKey: K)
        -> T?
    {
        
        if
            let realm = try? Realm(dbName: db),
            let objc = realm.object(ofType: type, forPrimaryKey: primaryKey) {
            return objc
        }
        return nil
    }
}

extension Realm.Configuration {
    
    func config(with dbName: Realm.DBName) -> Realm.Configuration {
        var config = self
        config.fileURL = fileURL(with: dbName)
        let schemaVersion: UInt64 = 50
        config.schemaVersion = schemaVersion
        config.migrationBlock = {
            if $1 < 4 {
                //                do {
                //                    try FileManager.default.removeItem(at: Realm.Configuration.realmDirectory)
                //                } catch let err {
                //                    print(err)
                //                }
            }
        }
        return config
    }
    
    func fileURL(with dbName: Realm.DBName) -> URL? {
        
        try? FileManager.default.createDirectory(at: Realm.Configuration.realmDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return Realm.Configuration.realmDirectory.appendingPathComponent(dbName.rawValue).appendingPathExtension("realm")
    }
    
    static let realmDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Config.appGroupID)!.appendingPathComponent("db.realm")
}


