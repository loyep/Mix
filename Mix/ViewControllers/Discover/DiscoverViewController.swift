//
//  DiscoverViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class DiscoverViewController: CollectionViewController {
    
    var viewModel = DiscoverViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.mix.registerClassOf(StatusCell.self)
        navigationItem.title = NSLocalizedString("Discover", comment: "")
    }
}

extension DiscoverViewController {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
}

extension DiscoverViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.results.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StatusCell = collectionView.mix.dequeueReusableCell(forIndexPath: indexPath)
        let status = viewModel.data(for: indexPath).status!
        cell.bind(for: status, delegate: self)
        registerForPreviewing(with: self, sourceView: cell)
        return cell
    }
}

class DiscoverCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width - StatusCell.CellInset.left - StatusCell.CellInset.right, height: 400)
        minimumLineSpacing = StatusCell.CellInset.top
        itemSize = estimatedItemSize
        sectionInset = StatusCell.CellInset
    }
}
