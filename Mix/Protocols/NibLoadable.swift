//
//  NibLoadable.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

protocol NibLoadable {
    
    static var mix_nibName: String { get }
}

extension UITableViewCell: NibLoadable {
    
    static var mix_nibName: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: NibLoadable {
    
    static var mix_nibName: String {
        return String(describing: self)
    }
}
