//
//  AccountViewController.swift
//  Mix
//
//  Created by Maxwell on 13/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class AccountViewController: BaseViewController {
    
    @IBOutlet weak var accountList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accountList.registerClassOf(AccountTableViewCell.self)
    }
    
}

extension AccountViewController: UITableViewDelegate {
    
}

extension AccountViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AccountTableViewCell = tableView.dequeueReusableCell(indexPath: indexPath)
        return cell
    }
}
