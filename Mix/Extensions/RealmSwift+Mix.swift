//
//  RealmSwift+Mix.swift
//  Mix
//
//  Created by Maxwell on 08/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import RealmSwift

public enum RealmError: Swift.Error {
    
    /// Realm Object Not Exist
    case realmObjectNotExist
    
}

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
        try self.init(configuration: Realm.Configuration().config(with: dbName))
    }
    
    struct DBName: RawRepresentable, ExpressibleByStringLiteral {
        
        static let `public`: DBName = "public"
        
        var rawValue: String
        
        init?(rawValue: String) {
            self.rawValue = rawValue
        }
        
        init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        init(unicodeScalarLiteral value: String) {
            self.rawValue = value
        }
        
        init(extendedGraphemeClusterLiteral value: String) {
            self.rawValue = value
        }
    }
    
    static func write(for db: Realm.DBName, task: @escaping () -> Void) throws
    {
        let realm = try Realm(dbName: db)
        try realm.write(task)
    }
    
    static func update<T: RealmSwift.Object, K>(
        _ type: T.Type,
        for db: Realm.DBName,
        of primaryKey: K,
        task: (T) -> Void)
        throws
    {
        let realm = try Realm(dbName: db)
        let objc = realm.object(ofType: type, forPrimaryKey: primaryKey)
        
        if let objc = objc {
            try realm.write { task(objc) }
        } else {
            throw RealmError.realmObjectNotExist
        }
    }
    
    static func update<T: RealmSwift.Object>(
        _ type: T.Type,
        for db: Realm.DBName,
        task: (T) -> Void) throws
    {
        let realm = try Realm(dbName: db)
        let s = realm.objects(type)
        try realm.write { s.forEach(task) }
    }
    
    static func add(
        _ objc: RealmSwift.Object,
        for db: Realm.DBName,
        update: Bool = true) throws
    {
        let realm = try Realm(dbName: db)
        try realm.write {
            realm.add(objc, update: update)
        }
    }
    
    static func add<S: Sequence>(
        _ objcs: S,
        for db: Realm.DBName,
        update: Bool = true) throws
        where S.Iterator.Element: RealmSwift.Object
    {
        
        let realm = try Realm(dbName: db)
        try realm.write {
            realm.add(objcs, update: update)
        }
    }
    
    static func objcs<T: RealmSwift.Object>(
        _ type: T.Type,
        for db: Realm.DBName)
        throws -> RealmSwift.Results<T>
    {
        return try Realm(dbName: db).objects(type)
    }
    
    static func objc<T: RealmSwift.Object, K>(
        _ type: T.Type,
        for db: Realm.DBName,
        of primaryKey: K)
        throws -> T?
    {
        let realm = try Realm(dbName: db)
        if let objc = realm.object(ofType: type, forPrimaryKey: primaryKey) {
            return objc
        }
        return nil
    }
    
    static func deleteAll(for db: DBName) throws {
        
        let realm = try Realm(dbName: db)
        try realm.write { realm.deleteAll() }
    }
    
    static func delete<T: RealmSwift.Object>(
        _ objc: T,
        for db: DBName) throws {
        
        let realm = try Realm(dbName: db)
        try realm.write { realm.delete(objc) }
    }
    
    static func delete<S: Sequence>(
        _ objcs: S,
        for db: DBName) throws
        where S.Iterator.Element:
        RealmSwift.Object
    {
        
        let realm = try Realm(dbName: db)
        try realm.write { realm.delete(objcs) }
    }
    
    static func delete<T: RealmSwift.Object>(
        _ type: T.Type,
        for db: DBName) throws
    {
        let realm = try Realm(dbName: db)
        let objcs = realm.objects(type)
        try realm.write { realm.delete(objcs) }
    }
}

extension Realm.Configuration {
    
    static let realmDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Config.appGroupID)!
    
    static let RealmVersion: UInt64 = 54
    
    func config(with dbName: Realm.DBName) -> Realm.Configuration {
        
        var config = self
        config.fileURL = fileURL(with: dbName)
        print("realmPath: \(config.fileURL!.absoluteString)")
        config.schemaVersion = Realm.Configuration.RealmVersion
        config.migrationBlock = {
            if $1 < 50 {
                do {
                    try FileManager.default.removeItem(at: Realm.Configuration.realmDirectory)
                } catch let err {
                    print(err)
                }
            }
        }
        
        return config
    }
    
    func fileURL(with dbName: Realm.DBName) -> URL? {
        
        let realmDirectory = Realm.Configuration.realmDirectory.appendingPathComponent("Realm")
        
        try? FileManager.default.createDirectory(at: realmDirectory, withIntermediateDirectories: true, attributes: nil)
        
        return realmDirectory.appendingPathComponent(dbName.rawValue).appendingPathExtension("realm")
    }
}


