//
//  ContactsViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import SwiftyWeibo

class ContactsViewController: BaseViewController {
    
    @IBOutlet weak var swipeTableView: SwipeTableView!
    
    var scroll: UIScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Contact", comment: "")
    }
    
}

extension ContactsViewController: SwipeTableViewDelegate {
    
    
}

extension ContactsViewController: SwipeTableViewDataSource {
    
    
    func numberOfSections(in swipeTableView: SwipeTableView) -> Int {
        return 2
    }
    
    func swipeTableView(_ swipeTableView: SwipeTableView, viewForItemAt index: Int, reusingView: UIScrollView) -> UIScrollView {
        return scroll
    }
    
}
