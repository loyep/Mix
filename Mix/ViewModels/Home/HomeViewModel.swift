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
import MixKit

final class HomeViewModel: Reactor {
    
    struct State {
        var statuses: [WeiboStatus] {
            return try! Realm(dbName: "userName").objects(WeiboStatus.self).sorted(byKeyPath: "id", ascending: false).mapArr()
        }
    }
    
    var initialState = State()
    
    enum Action {
        case reload
        case selected(IndexPath)
    }
    
    enum Mutation {
        case reload
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .reload:
            return Observable.just(Mutation.reload)
        case let .selected(indexPath)
            let status = currentState.statuses[indexPath.item]
            
            return 
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
}

