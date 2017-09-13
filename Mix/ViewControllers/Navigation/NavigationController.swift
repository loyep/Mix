//
//  NavigationController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        interactivePopGestureRecognizer?.delegate = self
        delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToViewController(viewController, animated: false)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension NavigationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        return true
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
}
