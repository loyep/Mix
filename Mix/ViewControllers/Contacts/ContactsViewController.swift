//
//  ContactsViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import SwiftyWeibo

class ContactsViewController: CollectionViewController {
    
    open override var collectionView: UICollectionView? {
        didSet {
            if collectionView == nil { return }
            collectionView!.alwaysBounceVertical = true
            view.addSubview(collectionView!)
            collectionView?.registerClassOf(BaseStatusesViewCell.self)
            collectionView!.snp.makeConstraints {
                $0.left.top.bottom.right.equalTo(view)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView?.registerClassOf(UICollectionViewCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Contact", comment: "")
    }
    
}

extension ContactsViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BaseStatusesViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        return cell
    }
    
}
