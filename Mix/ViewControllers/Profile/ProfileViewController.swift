//
//  ProfileViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    lazy var settingsButton: UIButton = {
        let settings = UIButton(type: .custom)
        settings.addTarget(self, action: #selector(ProfileViewController.showSettings), for: .touchUpInside)
        settings.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Settings", comment: ""),
                                                       attributes: [
                                                        NSForegroundColorAttributeName: UIColor.black
            ]), for: .normal)
        settings.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Settings", comment: ""),
                                                       attributes: [
                                                        NSForegroundColorAttributeName: UIColor.orange
            ]), for: .highlighted)
        settings.sizeToFit()
        return settings
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Profile", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    func showSettings() {
        let settings = SettingsViewController(style: .grouped)
        settings.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settings, animated: true)
    }
    
}
