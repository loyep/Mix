//
//  MixTarget.swift
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

/// A type that has MixCompatible extensions.
public protocol MixCompatible {
    /// Extended type
    associatedtype CompatibleType
    
    /// MixReusable extensions.
    static var mix: MixTarget<CompatibleType>.Type { get set }
    
    /// MixCompatible extensions.
    var mix: MixTarget<CompatibleType> { get set }
}

public extension MixCompatible {
    /// MixCompatible extensions.
    public static var mix: MixTarget<Self>.Type {
        get {
            return MixTarget<Self>.self
        }
        set { }
    }
    
    /// MixCompatible extensions.
    public var mix: MixTarget<Self> {
        get {
            return MixTarget(self)
        }
        set { }
    }
}

/// Extend NSObject with `mix` proxy.
extension NSObject: MixCompatible { }

