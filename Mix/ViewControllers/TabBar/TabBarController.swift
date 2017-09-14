//
//  TabBarController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    /// Ignore next selection or not.
    fileprivate var ignoreNextSelection = false
    
    /// Should hijack select action or not.
    open var shouldHijackHandler:  TabBarController.TabBarControllerShouldHijackHandler?
    /// Hijack select action.
    open var didHijackHandler: TabBarController.TabBarControllerDidHijackHandler?
    
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
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(Int(self.selectedIndex), forKey: "selectedIndex")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        self.selectedIndex = Int(coder.decodeInt32(forKey: "selectedIndex"))
    }
}

extension TabBarController {
    
    /// 是否需要自定义点击事件回调类型
    public typealias TabBarControllerShouldHijackHandler = ((_ tabBarController: UITabBarController, _ viewController: UIViewController, _ index: Int) -> (Bool))
    /// 自定义点击事件回调类型
    public typealias TabBarControllerDidHijackHandler = ((_ tabBarController: UITabBarController, _ viewController: UIViewController, _ index: Int) -> (Void))
    
    /// 打印异常
    open static func printError(_ description: String) {
        #if DEBUG
            print("ERROR: TabBarController catch an error '\(description)' \n")
        #endif
    }
    
    /// 当前tabBarController是否存在"More"tab
    open static func isShowingMore(_ tabBarController: UITabBarController?) -> Bool {
        return tabBarController?.moreNavigationController.parent != nil
    }
    
    /// Observer tabBarController's selectedViewController. change its selection when it will-set.
    open override var selectedViewController: UIViewController? {
        willSet {
            guard let newValue = newValue else {
                // if newValue == nil ...
                return
            }
            guard !ignoreNextSelection else {
                ignoreNextSelection = false
                return
            }
            guard let tabBar = self.tabBar as? TabBar, let items = tabBar.items, let index = viewControllers?.index(of: newValue) else {
                return
            }
            let value = (TabBarController.isShowingMore(self) && index > items.count - 1) ? items.count - 1 : index
            tabBar.select(itemAtIndex: value, animated: false)
        }
    }
    
    /// Observer tabBarController's selectedIndex. change its selection when it will-set.
    open override var selectedIndex: Int {
        willSet {
            guard !ignoreNextSelection else {
                ignoreNextSelection = false
                return
            }
            guard let tabBar = self.tabBar as? TabBar, let items = tabBar.items else {
                return
            }
            let value = (TabBarController.isShowingMore(self) && newValue > items.count - 1) ? items.count - 1 : newValue
            tabBar.select(itemAtIndex: value, animated: false)
        }
    }
    
    /// Customize set tabBar use KVC.
    open override func loadView() {
        super.loadView()
        setupTabBar()
    }
    
    /// Setup tabBar use KVC.
    fileprivate func setupTabBar() {
        let tabBar = { () -> TabBar in
            let tabBar = TabBar()
            tabBar.delegate = self
            tabBar.customDelegate = self
            tabBar.tabBarController = self
            return tabBar
        }()
        tabBar.items = self.tabBar.items
        self.setValue(tabBar, forKey: "tabBar")
    }
}

extension TabBarController: TabBarDelegate {
    
    // MARK: - TabBar delegate
    internal func tabBar(_ tabBar: UITabBar, shouldSelect item: UITabBarItem) -> Bool {
        if let idx = tabBar.items?.index(of: item), let vc = viewControllers?[idx] {
            return delegate?.tabBarController?(self, shouldSelect: vc) ?? true
        }
        return true
    }
    
    internal func tabBar(_ tabBar: UITabBar, shouldHijack item: UITabBarItem) -> Bool {
        if let idx = tabBar.items?.index(of: item), let vc = viewControllers?[idx] {
            return shouldHijackHandler?(self, vc, idx) ?? false
        }
        return false
    }
    
    internal func tabBar(_ tabBar: UITabBar, didHijack item: UITabBarItem) {
        if let idx = tabBar.items?.index(of: item), let vc = viewControllers?[idx] {
            didHijackHandler?(self, vc, idx)
        }
    }
    
    // MARK: - UITabBar delegate
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.index(of: item) else {
            return;
        }
        if idx == tabBar.items!.count - 1, TabBarController.isShowingMore(self) {
            ignoreNextSelection = true
            selectedViewController = moreNavigationController
            return;
        }
        if let vc = viewControllers?[idx] {
            ignoreNextSelection = true
            selectedIndex = idx
            delegate?.tabBarController?(self, didSelect: vc)
        }
    }
    
    open override func tabBar(_ tabBar: UITabBar, willBeginCustomizing items: [UITabBarItem]) {
        if let tabBar = tabBar as? TabBar {
            tabBar.updateLayout()
        }
    }
    
    open override func tabBar(_ tabBar: UITabBar, didEndCustomizing items: [UITabBarItem], changed: Bool) {
        if let tabBar = tabBar as? TabBar {
            tabBar.updateLayout()
        }
    }
}



