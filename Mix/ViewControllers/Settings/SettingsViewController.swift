//
//  SettingsViewController.swift
//  Mix
//
//  Created by Maxwell on 01/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var cacheLabel: UILabel!
    override func loadView() {
        super.loadView()
        tableView.registerClassOf(UITableViewCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Settings", comment: "")
        
        if ((navigationController?.presentingViewController) != nil) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(SettingsViewController.closeSettings))
        }
        
        KingfisherManager.shared.cache.calculateDiskCacheSize {
            self.cacheLabel.text = String(format: "%.2f MB", (Float($0/1024)/1024))
        }
    }
    
    @objc fileprivate func closeSettings() -> () {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}



