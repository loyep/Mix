//
//  HomeViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: CollectionViewController, StoryboardView {
    
    var disposeBag = DisposeBag()
    var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.mix.registerClassOf(StatusCell.self)
        navigationItem.title = NSLocalizedString("Home", comment: "")
    }
    
    func bind(reactor: HomeViewModel) {
        
        reactor.state.map { $0.statuses }
            .bind(to: collectionView!.rx.items(cellIdentifier: StatusCell.mix.reuseIdentifier)) { indexPath, status, cell in
                if let cell = cell as? StatusCell {
                    cell.bind(for: status)
                }
            }.disposed(by: disposeBag)
        
//        reactor.action.
    }
    
}


extension HomeViewController {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
}

extension HomeViewController {
    
    //    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //        return viewModel.results.count
    //    }
    //
    //    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //        let cell: StatusCell = collectionView.mix.dequeueReusableCell(forIndexPath: indexPath)
    //        if let status = viewModel.data(for: indexPath) {
    //            cell.bind(for: status, delegate: self)
    //        }
    //        registerForPreviewing(with: self, sourceView: cell)
    //        return cell
    //    }
}

class StatusCollectionViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width - StatusCell.CellInset.left - StatusCell.CellInset.right, height: 400)
        minimumLineSpacing = StatusCell.CellInset.top
        itemSize = estimatedItemSize
        sectionInset = StatusCell.CellInset
    }
}

