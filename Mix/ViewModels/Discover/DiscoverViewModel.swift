//
//  DiscoverViewModel.swift
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

final class DiscoverViewModel: Reactor {

    struct State {
        var statuses: [WeiboFavorites] {
            return try! Realm(dbName: "userName").objects(WeiboFavorites.self).sorted(byKeyPath: "id", ascending: false).mapArr()
        }
    }

    var initialState = State()

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

    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }
    
}
