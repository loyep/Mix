//
//  TableViewController.swift
//  Mix
//
//  Created by Maxwell on 14/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

open class TableViewController: UIViewController {
    
    @IBOutlet open var tableView: UITableView?
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        tableView?.mix.registerClassOf(UITableViewCell.self)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension TableViewController: UIViewControllerPreviewingDelegate {
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
    }
}

extension TableViewController: UITableViewDelegate {
    
    
}

extension TableViewController: UITableViewDataSource {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.mix.dequeueReusableCell()
    }
}
