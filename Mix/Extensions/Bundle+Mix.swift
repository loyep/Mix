//
//  Bundle+Mix.swift
//  Mix
//
//  Created by Maxwell on 2017/8/31.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation

extension Bundle {
    
    static var releaseVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var buildVersionNumber: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    static var bundleIdentifier: String? {
        return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    }
    
}
