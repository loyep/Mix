//
//  DiscoverViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class DiscoverNavigationController: NavigationController {
    
    @IBOutlet weak var discoverTabBarItem = TabBarItem(TabBarItemAnimateContentView(), title: Strings.DiscoverTitleDescription, image: UIImage(named: "tabbar_discover"), selectedImage: UIImage(named: "tabbar_discover_selected"))

}

class DiscoverViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Discover", comment: "")
    }

}
