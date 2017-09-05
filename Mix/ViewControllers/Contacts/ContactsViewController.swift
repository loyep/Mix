//
//  ContactsViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import SwiftyWeibo

class ContactsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Contact", comment: "")
        
//        let since_id: Int = realm.objects(WeiboHomeLine.self).max(ofProperty: "max_id") ?? 0
        weibo.request(SwiftyWeibo.Comments.byMe(sinceId: 0, maxId: 0, count: 0, page: 1)) { [weak self] result in
            guard let this = self else {
                return
            }
            do {
                let json = try result.dematerialize().mapJSON() as! [String: Any]
                print("\(json)")
//                guard let realm = try? Realm() else {
//                    return
//                }
//                try! realm.write {
//                    let homeLine = realm.create(WeiboHomeLine.self, value: json, update: true)
//                    homeLine.max_id = homeLine.statuses.max(ofProperty: "id") ?? 0
//                    this.dataSource += homeLine.statuses
//                }
            } catch {
                
            }
        }
    }

}
