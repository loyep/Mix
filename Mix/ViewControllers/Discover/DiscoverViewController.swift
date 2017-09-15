//
//  DiscoverViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyWeibo
import SwiftyJSON

class DiscoverViewController: CollectionViewController {
    
    let realm: Realm = try! Realm(dbName: "userName")
    
    lazy var results: Results<WeiboFavorites> = {
        return self.realm.objects(WeiboFavorites.self).sorted(byKeyPath: "favoritedTime", ascending: false)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.registerClassOf(StatusCell.self)
        navigationItem.title = NSLocalizedString("Discover", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        return
//        weibo.request(SwiftyWeibo.Statuses.favorites(count: 50, page: 1)) { [weak self] result in
//            guard let this = self else {
//                return
//            }
//            do {
//                let json = JSON(data: try result.dematerialize().data)
//                var favorites: [WeiboFavorites] = []
//                json["favorites"].arrayValue.forEach {
//                    favorites.append(WeiboFavorites($0))
//                }
//                this.realm.beginWrite()
//                this.realm.add(favorites, update: true)
//                try? this.realm.commitWrite()
//            } catch {
//                
//            }
//        }
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
        return results.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StatusCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        let favorite = results[indexPath.row]
        cell.bind(for: favorite.status)
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
