//
//  Reusable.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

public struct MixTarget<Base> {
    /// Base object to extend.
    public let base: Base
    
    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has MixReusable extensions.
public protocol MixReusable {
    /// Extended type
    associatedtype ReusableType
    
    /// MixReusable extensions.
    static var mix: MixTarget<ReusableType>.Type { get set }
    
    /// MixReusable extensions.
    var mix: MixTarget<ReusableType> { get set }
}

extension MixReusable {
    /// MixReusable extensions.
    public static var mix: MixTarget<Self>.Type {
        get {
            return MixTarget<Self>.self
        }
        set {
            
        }
    }
    
    /// MixReusable extensions.
    public var mix: MixTarget<Self> {
        get {
            return MixTarget(self)
        }
        set {
            
        }
    }
}

/// Extend NSObject with `mix` proxy.
extension NSObject: MixReusable { }

extension MixTarget where Base: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension MixTarget where Base: UITableViewHeaderFooterView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension MixTarget where Base: UICollectionReusableView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension MixTarget where Base: UIViewController {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

