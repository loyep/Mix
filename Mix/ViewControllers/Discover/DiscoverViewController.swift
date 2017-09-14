//
//  DiscoverViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyWeibo
import SwiftyJSON

class DiscoverViewController: UIViewController {
    
    let realm: Realm = try! Realm(dbName: "userName")
    
    lazy var results: Results<WeiboStatus> = {
        return self.realm.objects(WeiboStatus.self).sorted(byKeyPath: "id", ascending: false)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Discover", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        weibo.request(SwiftyWeibo.Statuses.favorites(count: 50, page: 1)) { [weak self] result in
            guard let this = self else {
                return
            }
            do {
                let json = JSON(data: try result.dematerialize().data)
                var favorites: [WeiboFavorites] = []
                json["favorites"].arrayValue.forEach {
                    favorites.append(WeiboFavorites($0))
                }
                this.realm.beginWrite()
                this.realm.add(favorites, update: true)
                try? this.realm.commitWrite()
            } catch {
                
            }
        }
    }

}
