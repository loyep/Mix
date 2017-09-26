//
//  ReusableView+Mix.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

// MARK: - UITableViewCell
public extension MixTarget where Base: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - UITableViewHeaderFooterView
public extension MixTarget where Base: UITableViewHeaderFooterView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - UICollectionReusableView
public extension MixTarget where Base: UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - UIViewController
public extension MixTarget where Base: UIViewController {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - UITableView
public extension MixTarget where Base: UITableView {
    
//    enum TableWayToUpdate {
//        
//        case none
//        case reloadData
//        case reloadIndexPaths([IndexPath])
//        case insert([IndexPath])
//        
//        var needsLabor: Bool {
//            switch self {
//            case .none:
//                return false
//            case .reloadData, .reloadIndexPaths, .insert:
//                return true
//            }
//        }
//        
//        public func performWithTableView(_ tableView: UITableView) {
//            switch self {
//            case .none:
//                print("tableView WayToUpdate: None")
//            case .reloadData:
//                print("tableView WayToUpdate: ReloadData")
//                SafeDispatch.async {
//                    tableView.reloadData()
//                }
//            case .reloadIndexPaths(let indexPaths):
//                print("tableView WayToUpdate: ReloadIndexPaths")
//                SafeDispatch.async {
//                    tableView.reloadRows(at: indexPaths, with: .none)
//                }
//            case .insert(let indexPaths):
//                print("tableView WayToUpdate: Insert")
//                SafeDispatch.async {
//                    tableView.insertRows(at: indexPaths, with: .none)
//                }
//            }
//        }
//    }
    
    public func registerClassOf<T: UITableViewCell>(_: T.Type) {
        base.register(T.self, forCellReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    public func registerNibOf<T: UITableViewCell>(_: T.Type) {
        let nib = UINib(nibName: T.mix.reuseIdentifier, bundle: nil)
        base.register(nib, forCellReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    public func registerHeaderFooterClassOf<T: UITableViewHeaderFooterView>(_: T.Type) {
        base.register(T.self, forHeaderFooterViewReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    public func dequeueReusableCell<T: UITableViewCell>() -> T {
        guard let cell = base.dequeueReusableCell(withIdentifier: T.mix.reuseIdentifier) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix.reuseIdentifier)")
        }
        return cell
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        guard let cell = base.dequeueReusableCell(withIdentifier: T.mix.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix.reuseIdentifier)")
        }
        return cell
    }
    
    public func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>() -> T {
        guard let view = base.dequeueReusableHeaderFooterView(withIdentifier: T.mix.reuseIdentifier) as? T else {
            fatalError("Could not dequeue HeaderFooter with identifier: \(T.mix.reuseIdentifier)")
        }
        return view
    }
}

// MARK: - UICollectionView
public extension MixTarget where Base: UICollectionView {
    
//    enum CollectionWayToUpdate {
//
//        case none
//        case reloadData
//        case insert([IndexPath])
//
//        var needsLabor: Bool {
//            switch self {
//            case .none:
//                return false
//            case .reloadData, .insert:
//                return true
//            }
//        }
//
//        public func performWithCollectionView(_ collectionView: UICollectionView) {
//            switch self {
//            case .none:
//                print("collectionView WayToUpdate: None")
//            case .reloadData:
//                print("collectionView WayToUpdate: ReloadData")
//                SafeDispatch.async {
//                    collectionView.reloadData()
//                }
//            case .insert(let indexPaths):
//                print("collectionView WayToUpdate: Insert")
//                SafeDispatch.async {
//                    collectionView.insertItems(at: indexPaths)
//                }
//            }
//        }
//    }
    
    public func registerClassOf<T: UICollectionViewCell>(_: T.Type) {
        base.register(T.self, forCellWithReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    public func registerNibOf<T: UICollectionViewCell>(_: T.Type) {
        let nib = UINib(nibName: T.mix.reuseIdentifier, bundle: nil)
        base.register(nib, forCellWithReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    public func registerHeaderNibOf<T: UICollectionReusableView>(_: T.Type) {
        let nib = UINib(nibName: T.mix.reuseIdentifier, bundle: nil)
        base.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    public func registerFooterClassOf<T: UICollectionReusableView>(_: T.Type) {
        base.register(T.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = base.dequeueReusableCell(withReuseIdentifier: T.mix.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix.reuseIdentifier)")
        }
        return cell
    }
    
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T {
        guard let view = base.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.mix.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.mix.reuseIdentifier), kind: \(kind)")
        }
        return view
    }
}
