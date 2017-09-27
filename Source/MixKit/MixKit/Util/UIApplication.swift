//
//  UIApplication.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit

public extension Mix where Base: UIApplication {
    
    public static func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    public func topViewController() -> UIViewController? {
        return UIApplication.mix.topViewController(base: base.keyWindow?.rootViewController)
    }
}
