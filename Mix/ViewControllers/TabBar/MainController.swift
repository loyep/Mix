//
//  MainController.swift
//  Mix
//
//  Created by Maxwell on 2017/10/9.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import SwiftyWeibo

class MainController: TabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        shouldHijackHandler = {
            tabbarController, viewController, index in
            if index == 2 {
                return true
            }
            return false
        }
        
        didHijackHandler = {
            tabbarController, viewController, index in
            DispatchQueue.main.async {
                let plus = NavigationController(rootViewController: PlusViewController())
                tabbarController.present(plus, animated: true, completion: nil)
            }
        }
        
        guard let count = try? Realm.objcs(WeiboEmotion.self, for: .public).count, count == 0 else {
            return
        }
        
        weibo.request(SwiftyWeibo.Statuses.emotions) { result in
            do {
                let json = JSON(data: try result.dematerialize().data)
                var emotions: [WeiboEmotion] = []
                json.array?.forEach {
                    emotions.append(WeiboEmotion($0))
                }
                try? Realm.add(emotions, for: .public)
            } catch {}
        }
    }

}
