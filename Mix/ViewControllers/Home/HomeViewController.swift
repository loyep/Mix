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

class HomeViewController: UITableViewController {
    
    var count: Int = 0
    var dataSource: [WeiboStatus] = [] {
        didSet {
            let count = dataSource.count
            self.count = dataSource.count
            guard self.count > count else {
                return
            }
            self.tableView.insertRows(at: Array(sequence(first: IndexPath(row: 0, section: 0), next: {
                return ($0.row + 1 < (self.count - count)) ? IndexPath(row: $0.row + 1, section: 0) : nil
            })), with: .top)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 300
        guard let realm = try? Realm() else {
            return
        }
        dataSource += realm.objects(WeiboStatus.self)
        tableView.registerClassOf(WeiboTableViewCell.self)
        navigationItem.title = NSLocalizedString("Home", comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let realm = try? Realm() else {
            return
        }
        
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
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeiboTableViewCell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.bindViewModel(self.dataSource[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let status: WeiboStatus = dataSource[indexPath.row]
        HomeViewController.dequCell.bindViewModel(status)
        return HomeViewController.dequCell.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width, height: CGFloat(MAXFLOAT))).height
    }
    
    static let dequCell: WeiboTableViewCell = WeiboTableViewCell(style: .default, reuseIdentifier: WeiboTableViewCell.mix_reuseIdentifier)
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
