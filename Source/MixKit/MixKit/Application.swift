//
//  Application.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation

open class Application {
    
    var context: MixContext?
    var enableException = false
    
    static let `default` = Application()
    
    public init() {
        
    }
}
