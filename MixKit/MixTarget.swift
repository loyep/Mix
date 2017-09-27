//
//  MixTarget.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

public struct Mix<Base> {
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
    static var mix: Mix<CompatibleType>.Type { get }
    
    /// MixCompatible extensions.
    var mix: Mix<CompatibleType> { get }
}

public extension MixCompatible {
    /// MixCompatible extensions.
    public static var mix: Mix<Self>.Type {
        get {
            return Mix<Self>.self
        }
    }
    
    /// MixCompatible extensions.
    public var mix: Mix<Self> {
        get {
            return Mix(self)
        }
    }
}

/// Extend NSObject with `mix` proxy.
extension NSObject: MixCompatible { }
