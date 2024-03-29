//
//  UserDefaultsService.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

//import Foundation
//
//extension UserDefaultsKey {
//    static var tasks: Key<[[String: Any]]> { return "tasks" }
//}
//
//protocol UserDefaultsServiceType {
//    func value<T>(forKey key: UserDefaultsKey<T>) -> T?
//    func set<T>(value: T?, forKey key: UserDefaultsKey<T>)
//}
//
//final class UserDefaultsService: BaseService, UserDefaultsServiceType {
//
//    private var defaults: UserDefaults {
//        return UserDefaults.standard
//    }
//
//    func value<T>(forKey key: UserDefaultsKey<T>) -> T? {
//        return self.defaults.value(forKey: key.key) as? T
//    }
//
//    func set<T>(value: T?, forKey key: UserDefaultsKey<T>) {
//        self.defaults.set(value, forKey: key.key)
//        self.defaults.synchronize()
//    }
//
//}

