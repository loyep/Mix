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
    
    var commentView: UICollectionView?
    
    var statusesView: UICollectionView?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupUI()
    }
    
    func setupUI() {
        let comment = CommentsViewController()
        let statuses = StatusesViewController()
        addChildViewController(comment)
        addChildViewController(statuses)
        commentView = comment.collectionView
        statusesView = statuses.collectionView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
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
        switch index {
        case 0:
            return commentView!
        default:
            return statusesView!
        }
    }
    
}
