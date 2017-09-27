//
//  RealmObserver.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

/// retains target realm object until it receives a .Completed or .Error event or the observer is being deinitialized
class RealmObserver<E>: ObserverType {
    var realm: Realm?
    var configuration: Realm.Configuration?
    
    let binding: (Realm?, E, Error?) -> Void
    
    init(realm: Realm, binding: @escaping (Realm?, E, Error?) -> Void) {
        self.realm = realm
        self.binding = binding
    }
    
    init(configuration: Realm.Configuration, binding: @escaping (Realm?, E, Error?) -> Void) {
        self.configuration = configuration
        self.binding = binding
    }
    
    /// Binds next element
    ///
    /// - Parameter event: event
    func on(_ event: Event<E>) {
        switch event {
        case .next(let element):
            //this will "cache" the realm on this thread, until completed/errored
            if let configuration = configuration, realm == nil {
                do {
                    let realm = try Realm(configuration: configuration)
                    binding(realm, element, nil)
                } catch let e {
                    binding(nil, element, e)
                }
                return;
            }
            
            guard let realm = realm else {
                fatalError("No realm in RealmObserver at time of a .Next event")
            }
            
            binding(realm, element, nil)
            
        case .error:
            realm = nil
        case .completed:
            realm = nil
        }
    }
    
    /// Erases the type of observer
    ///
    /// - Returns: AnyObserver, type erased observer
    func asObserver() -> AnyObserver<E> {
        return AnyObserver(eventHandler: on)
    }
    
    deinit {
        realm = nil
    }
}
