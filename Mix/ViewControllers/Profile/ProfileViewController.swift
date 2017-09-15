//
//  ProfileViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class ProfileViewController: TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Profile", comment: "")
    }
    
    @IBAction func showSettings(_ sender: UIBarButtonItem) {
        let settings = Storyboard.settings.scene()
        navigationController?.pushViewController(settings, animated: true)
    }
}
