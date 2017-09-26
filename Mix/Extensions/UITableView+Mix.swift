//
//  UITableView+Mix.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

extension MixTarget where Base: UITableView {
    
    enum TableWayToUpdate {
        
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

extension MixTarget where Base: UITableView {
    
    func registerClassOf<T: UITableViewCell>(_: T.Type) {
        
        base.register(T.self, forCellReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    func registerNibOf<T: UITableViewCell>(_: T.Type) {
        
        let nib = UINib(nibName: T.mix.reuseIdentifier, bundle: nil)
        base.register(nib, forCellReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    func registerHeaderFooterClassOf<T: UITableViewHeaderFooterView>(_: T.Type) {
        
        base.register(T.self, forHeaderFooterViewReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        
        guard let cell = base.dequeueReusableCell(withIdentifier: T.mix.reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix.reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        guard let cell = base.dequeueReusableCell(withIdentifier: T.mix.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix.reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T {
        guard let view = base.dequeueReusableHeaderFooterView(withIdentifier: T.mix.reuseIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooter with identifier: \(T.mix.reuseIdentifier)")
        }
        
        return view
    }
}

