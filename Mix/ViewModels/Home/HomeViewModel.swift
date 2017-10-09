//
//  HomeViewModel.swift
//  Mix
//
//  Created by Maxwell on 2017/10/9.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyWeibo
import SwiftyJSON
import RxSwift

final class HomeViewModel: Reactor {
    
    struct State {
        var statuses: [WeiboStatus] = []
    }
    
    var initialState = State()
    
    let realm: Realm = try! Realm(dbName: "userName")
    
    lazy var results: Results<WeiboStatus> = {
        return realm.objects(WeiboStatus.self).sorted(byKeyPath: "id", ascending: false)
    }()
    
    enum Action {
        case reload
    }
    
    enum Mutation {
        case reload
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reload:
            return Observable.just(Mutation.reload)
        }
    }
}

