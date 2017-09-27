//
//  UIApplication.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit

public extension Mix where Base: UIApplication {
    
    public static func topViewController(of viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        return UIViewController.mix.topViewController(of: viewController)
    }
    
    public var topViewController: UIViewController? {
        return UIViewController.mix.topViewController(of: base.keyWindow?.rootViewController)
    }
}
