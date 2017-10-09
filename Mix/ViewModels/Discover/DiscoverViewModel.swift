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

class DiscoverViewModel: NSObject {
    
    let realm: Realm = try! Realm(dbName: "userName")
    
    lazy var results: Results<WeiboFavorites> = {
        return self.realm.objects(WeiboFavorites.self).sorted(byKeyPath: "favoritedTime", ascending: false)
    }()
    
    func data(for indexPath: IndexPath) -> WeiboFavorites {
        return results[indexPath.row]
    }
    
}
