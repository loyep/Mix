//
//  ProfileViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Profile", comment: "")
    }
    
    @IBAction func showSettings(_ sender: UIBarButtonItem) {
        let settings = Storyboard.settings.scene()
        settings.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settings, animated: true)
    }
}

class ProfileNavigationController: NavigationController {
    
    @IBOutlet weak var profileTabBarItem = TabBarItem(TabBarItemAnimateContentView(), title: Strings.ProfileTitleDescription, image: UIImage(named: "tabbar_profile"), selectedImage: UIImage(named: "tabbar_profile_selected"))
    
}
