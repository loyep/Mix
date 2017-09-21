//
//  BaseStatusesViewController.swift
//  Mix
//
//  Created by Maxwell on 19/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import SnapKit

class BaseStatusesViewController: CollectionViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
