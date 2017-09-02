//
//  RealmWebImage.swift
//  Mix
//
//  Created by Maxwell on 2017/9/2.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation
import RealmSwift

class RealmWebImage: Object {
    
    @objc override static func primaryKey() -> String? {
        return "imageUrl"
    }
    dynamic var imageUrl: String = ""
    
    dynamic var webCacheData = NSData()
    
    dynamic var webCacheSize: Double = 0
}

extension UIImage {
    
}
