//
//  CollectionViewController.swift
//  Mix
//
//  Created by Maxwell on 14/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import MixKit

open class CollectionViewController: UIViewController {
    
    @IBOutlet open var collectionView: UICollectionView?
    
    open fileprivate(set) var collectionViewLayout: UICollectionViewLayout = .init()
    
    var clearsSelectionOnViewWillAppear: Bool = true
    
    public convenience init(collectionViewLayout layout: UICollectionViewLayout) {
        self.init(nibName: nil, bundle: nil)
        collectionViewLayout = layout
    }
    
    open override func loadView() {
        super.loadView()
        loadCollectionView()
    }
    
    fileprivate func loadCollectionView() {
        guard collectionView == nil else { return }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.theme_backgroundColor = globalViewBackgroundColorPicker
        collectionView?.alwaysBounceVertical = true
        collectionView?.mix.registerClassOf(UICollectionViewCell.self)
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if clearsSelectionOnViewWillAppear,
            collectionView?.allowsSelection ?? false,
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

extension CollectionViewController: UIViewControllerPreviewingDelegate {
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        return nil
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.mix.dequeueReusableCell(forIndexPath: indexPath)
    }
}
