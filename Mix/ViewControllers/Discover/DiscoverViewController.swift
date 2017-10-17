//
//  DiscoverViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DiscoverViewController: CollectionViewController, StoryboardView {

    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        reactor = DiscoverViewModel()
        collectionView?.mix.registerClassOf(StatusCell.self)
        navigationItem.title = NSLocalizedString("Discover", comment: "")
    }

    func bind(reactor: DiscoverViewModel) {
        reactor.state.map { $0.statuses }
                .bind(to: collectionView!.rx.items(cellIdentifier: StatusCell.mix.reuseIdentifier, cellType: StatusCell.self)) { (row, status, cell) in
                    cell.bind(for: status)
                }
                .disposed(by: disposeBag)
        collectionView?.rx.itemSelected
                .subscribe(onNext: { [weak self, weak reactor] indexPath in
                    guard let `self` = self else { return }
                    print("\(indexPath) \(String(describing: self.reactor)) \(String(describing: reactor))")
                })
                .disposed(by: disposeBag)
    }
}

extension DiscoverViewController {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
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
