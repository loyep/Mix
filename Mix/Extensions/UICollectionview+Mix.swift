//
//  UICollectionview+Mix.swift
//  Mix
//
//  Created by Maxwell on 06/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    enum WayToUpdate {
        
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

extension UICollectionView {
    
    func registerClassOf<T: UICollectionViewCell>(_: T.Type) {
        
        register(T.self, forCellWithReuseIdentifier: T.mix_reuseIdentifier)
    }
    
    func registerNibOf<T: UICollectionViewCell>(_: T.Type) {
        
        let nib = UINib(nibName: T.mix_nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.mix_reuseIdentifier)
    }
    
    func registerHeaderNibOf<T: UICollectionReusableView>(_: T.Type) {
        
        let nib = UINib(nibName: T.mix_nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: T.mix_reuseIdentifier)
    }
    
    func registerFooterClassOf<T: UICollectionReusableView>(_: T.Type) {
        
        register(T.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: T.mix_reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.mix_reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.mix_reuseIdentifier)")
        }
        
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, forIndexPath indexPath: IndexPath) -> T {
        
        guard let view = self.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.mix_reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue supplementary view with identifier: \(T.mix_reuseIdentifier), kind: \(kind)")
        }
        
        return view
    }
}
