//
//  Reusable.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

protocol Reusable: class {
    
    static var mix_reuseIdentifier: String { get }
}

extension UITableViewCell: Reusable {
    
    static var mix_reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView: Reusable {
    
    static var mix_reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: Reusable {
    
    static var mix_reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIViewController: Reusable {

    static var mix_reuseIdentifier: String {
        return String(describing: self)
    }
}
