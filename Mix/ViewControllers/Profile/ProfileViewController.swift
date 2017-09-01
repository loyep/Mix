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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(ProfileViewController.showSettings))
    }
    
    func showSettings() {
        let settings = SettingsViewController(style: .grouped)
        settings.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settings, animated: true)
    }

}
