//
//  HomeViewController.swift
//  Mix
//
//  Created by Maxwell on 30/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import SwiftyWeibo
import RealmSwift
import SwiftyJSON

class HomeViewController: CollectionViewController {
    
    var notificationToken: NotificationToken? = nil
    
    let realm: Realm = try! Realm(dbName: "userName")
    
    lazy var results: Results<WeiboStatus> = {
        return self.realm.objects(WeiboStatus.self).sorted(byKeyPath: "id", ascending: false)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.registerClassOf(StatusCell.self)
        navigationItem.title = NSLocalizedString("Home", comment: "")
        //        return
        // Observe Realm Notifications
        //        notificationToken = results.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
        //            guard let statusView = self?.statusView else { return }
        //            switch changes {
        //            case .initial:
        //                // Results are now populated and can be accessed without blocking the UI
        //                statusView.reloadData()
        //                break
        //            case .update(_, let deletions, let insertions, let modifications):
        //                // Query results have changed, so apply them to the UITableView
        //                statusView.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))
        //                statusView.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0) }))
        //                statusView.reloadItems(at: modifications.map({ IndexPath(row: $0, section: 0) }))
        //                break
        //            case .error(let error):
        //                // An error occurred while opening the Realm file on the background worker thread
        //                fatalError("\(error)")
        //                break
        //            }
        //        }
        //
        //        notificationToken?.stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        return
        let since_id: Int64 = results.max(ofProperty: "id") ?? 0
        weibo.request(SwiftyWeibo.Statuses.homeTimeline(sinceId: 0, maxId: 0, count: (since_id == 0 ? 5: 20), page: 1, feature: .all)) { [weak self] result in
            guard let this = self else {
                return
            }
            do {
                let json = JSON(data: try result.dematerialize().data)
                var statuses: [WeiboStatus] = []
                json["statuses"].arrayValue.forEach {
                    statuses.append(WeiboStatus($0))
                }
                this.realm.beginWrite()
                this.realm.add(statuses, update: true)
                try? this.realm.commitWrite()
                this.collectionView?.reloadData()
            } catch {
                
            }
        }
    }
}


extension HomeViewController {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
}

extension HomeViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StatusCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.bind(for: results[indexPath.item])
        return cell
    }
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

