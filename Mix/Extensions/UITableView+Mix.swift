//
//  UITableView+Mix.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

extension UITableView {
    
    enum WayToUpdate {
        
        case none
        case reloadData
        case reloadIndexPaths([IndexPath])
        case insert([IndexPath])
        
        var needsLabor: Bool {
            
            switch self {
            case .none:
                return false
            case .reloadData:
                return true
            case .reloadIndexPaths:
                return true
            case .insert:
                return true
            }
        }
        
        func performWithTableView(_ tableView: UITableView) {
            
            switch self {
                
            case .none:
                print("tableView WayToUpdate: None")
                break
                
            case .reloadData:
                print("tableView WayToUpdate: ReloadData")
                SafeDispatch.async {
                    tableView.reloadData()
                }
                
            case .reloadIndexPaths(let indexPaths):
                print("tableView WayToUpdate: ReloadIndexPaths")
                SafeDispatch.async {
                    tableView.reloadRows(at: indexPaths, with: .none)
                }
                
            case .insert(let indexPaths):
                print("tableView WayToUpdate: Insert")
                SafeDispatch.async {
                    tableView.insertRows(at: indexPaths, with: .none)
                }
            }
        }
    }
}

extension UITableView {
    
    func registerClassOf<T: UITableViewCell>(_: T.Type) where T: Reusable {
        
        register(T.self, forCellReuseIdentifier: T.mix_reuseIdentifier)
    }
    
    func registerNibOf<T: UITableViewCell>(_: T.Type) where T: Reusable, T: NibLoadable {
        
        let nib = UINib(nibName: T.mix_nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.mix_reuseIdentifier)
    }
    
    func registerHeaderFooterClassOf<T: UITableViewHeaderFooterView>(_: T.Type) where T: Reusable {
        
        register(T.self, forHeaderFooterViewReuseIdentifier: T.mix_reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>() -> T where T: Reusable {
        
        guard let cell = self.dequeueReusableCell(withIdentifier: T.mix_reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix_reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.mix_reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix_reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T where T: Reusable {
        guard let view = self.dequeueReusableHeaderFooterView(withIdentifier: T.mix_reuseIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooter with identifier: \(T.mix_reuseIdentifier)")
        }
        
        return view
    }
}

