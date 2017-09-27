//
//  UIViewController.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation

public extension Mix where Base: UIViewController {
    
    public func bind() -> () {
        print(String(describing: base))
    }
    
    public var topViewController: UIViewController? {
        return UIViewController.mix.topViewController(of: base)
    }
    
    public static var topVewController: UIViewController? {
        return self.topViewController()
    }
    
    internal static func topViewController(of viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return topViewController(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return topViewController(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return topViewController(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
            pageViewController.viewControllers?.count == 1 {
            return topViewController(of: pageViewController.viewControllers?.first)
        }
        
        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return topViewController(of: childViewController)
            }
        }
        
        return viewController
    }
}
