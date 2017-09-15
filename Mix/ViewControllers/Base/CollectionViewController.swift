//
//  CollectionViewController.swift
//  Mix
//
//  Created by Maxwell on 14/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

open class CollectionViewController: BaseViewController {
    
    @IBOutlet open var collectionView: UICollectionView?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var clearsSelectionOnViewWillAppear: Bool = true
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.theme_backgroundColor = globalViewBackgroundColorPicker
        collectionView?.alwaysBounceVertical = true
        collectionView?.registerClassOf(UICollectionViewCell.self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if clearsSelectionOnViewWillAppear,
            let selectedItems = collectionView?.indexPathsForSelectedItems,
            selectedItems.count > 0 {
            let allowsSelection = collectionView!.allowsSelection
            collectionView!.allowsSelection = false
            collectionView!.allowsSelection = allowsSelection
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CollectionViewController: UICollectionViewDelegate {
    
    
}

extension CollectionViewController: UICollectionViewDataSource {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(forIndexPath: indexPath)
    }
}
