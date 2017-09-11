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

class HomeViewController: UIViewController {
    
    var notificationToken: NotificationToken? = nil
    
    let realm: Realm = try! Realm(dbName: .user)
    
    var results: Results<WeiboStatus> {
        return self.realm.objects(WeiboStatus.self).sorted(byKeyPath: "id", ascending: false)
    }
    
    lazy var statusView: UICollectionView = {
        let layout = StatusCollectionViewLayout()
        let statusView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        statusView.delegate = self
        statusView.dataSource = self
        statusView.backgroundColor = .white
        return statusView
    }()
    
    override func loadView() {
        view = statusView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusView.registerClassOf(StatusCell.self)
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
        
        notificationToken?.stop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        return
        let since_id: Int64 = results.max(ofProperty: "id") ?? 0
        weibo.request(SwiftyWeibo.Statuses.homeTimeline(sinceId: 0, maxId: 0, count: (since_id == 0 ? 200: 20), page: 1, feature: .all)) { [weak self] result in
            guard let this = self else {
                return
            }
            do {
                let json = JSON(data: try result.dematerialize().data)
                var statuses: [WeiboStatus] = []
                json["statuses"].arrayValue.forEach {
                    statuses.append(WeiboStatus($0, isValid: false))
                }
                this.realm.beginWrite()
                this.realm.add(statuses, update: true)
                try? this.realm.commitWrite()
            } catch {
                
            }
        }
    }
}


extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StatusCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.bind(for: results[indexPath.item])
        return cell
    }
}


