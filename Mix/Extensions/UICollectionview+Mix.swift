//
//  UICollectionview+Mix.swift
//  Mix
//
//  Created by Maxwell on 06/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

extension MixTarget where Base: UICollectionView {
    
    enum CollectionWayToUpdate {
        
        case none
        case reloadData
        case insert([IndexPath])
        
        var needsLabor: Bool {
            
            switch self {
            case .none:
                return false
            case .reloadData:
                return true
            case .insert:
                return true
            }
        }
        
        func performWithCollectionView(_ collectionView: UICollectionView) {
            
            switch self {
                
            case .none:
                print("collectionView WayToUpdate: None")
                break
                
            case .reloadData:
                print("collectionView WayToUpdate: ReloadData")
                SafeDispatch.async {
                    collectionView.reloadData()
                }
                
            case .insert(let indexPaths):
                print("collectionView WayToUpdate: Insert")
                SafeDispatch.async {
                    collectionView.insertItems(at: indexPaths)
                }
            }
        }
    }
}

extension MixTarget where Base: UICollectionView {
    
    func registerClassOf<T: UICollectionViewCell>(_: T.Type) {
        
        base.register(T.self, forCellWithReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    func registerNibOf<T: UICollectionViewCell>(_: T.Type) {
        
        let nib = UINib(nibName: T.mix.reuseIdentifier, bundle: nil)
        base.register(nib, forCellWithReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    func registerHeaderNibOf<T: UICollectionReusableView>(_: T.Type) {
        
        let nib = UINib(nibName: T.mix.reuseIdentifier, bundle: nil)
        base.register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    func registerFooterClassOf<T: UICollectionReusableView>(_: T.Type) {
        
        base.register(T.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: T.mix.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = base.dequeueReusableCell(withReuseIdentifier: T.mix.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix.reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T {
        
        guard let view = base.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.mix.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.mix.reuseIdentifier), kind: \(kind)")
        }
        
        return view
    }
}
