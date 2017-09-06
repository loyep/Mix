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

class HomeViewController: UIViewController {
    
    lazy var statusView: UICollectionView = {
        let layout = StatusCollectionViewLayout()
        let statusView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        statusView.delegate = self
        statusView.dataSource = self
        statusView.backgroundColor = .white
        return statusView
    }()
    var count: Int = 0
    var dataSource: [WeiboStatus] = [] {
        didSet {
            let count = self.count
            self.count = dataSource.count
            guard self.count > count else {
                return
            }
            
            //            if count == 0 {
//            self.tableView.reloadData()
            //            } else {
            //                self.tableView.insertRows(at: Array(sequence(first: IndexPath(row: 0, section: 0), next: {
            //                    return ($0.row + 1 < (self.count - count)) ? IndexPath(row: $0.row + 1, section: 0) : nil
            //                })), with: .automatic)
            //            }
        }
    }
    
    override func loadView() {
        view = statusView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let realm = try? Realm() else {
            return
        }
        dataSource += realm.objects(WeiboStatus.self)
        statusView.registerClassOf(StatusCell.self)
        navigationItem.title = NSLocalizedString("Home", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let realm = try? Realm() else {
            return
        }
        return
        let since_id: Int = realm.objects(WeiboHomeLine.self).max(ofProperty: "max_id") ?? 0
        weibo.request(SwiftyWeibo.Statuses.homeTimeline(sinceId: since_id, maxId: 0, count: (since_id == 0 ? 200: 20), page: 1, feature: .all)) { [weak self] result in
            guard let this = self else {
                return
            }
            do {
                let json = try result.dematerialize().mapJSON() as! [String: Any]
                guard let realm = try? Realm() else {
                    return
                }
                try! realm.write {
                    let homeLine = realm.create(WeiboHomeLine.self, value: json, update: true)
                    homeLine.max_id = homeLine.statuses.max(ofProperty: "id") ?? 0
                    this.dataSource += homeLine.statuses
                }
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
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: StatusCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.bindViewModel(self.dataSource[indexPath.row])
        return cell
    }
    
}


