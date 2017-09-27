//
//  MixTarget.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import CoreGraphics
#if os(iOS) || os(tvOS)
    import UIKit.UIGeometry
#endif

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
public protocol MixCompatible { }

public extension MixCompatible where Self: NSObject {
    
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

extension MixCompatible where Self: Any {
    
    /// Makes it available to set properties with closures just after initializing and copying the value types.
    ///
    ///     let frame = CGRect().with {
    ///       $0.origin.x = 10
    ///       $0.size.width = 100
    ///     }
    public func with(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
    
    /// Makes it available to execute something with closures.
    ///
    ///     UserDefaults.standard.do {
    ///       $0.set("devxoul", forKey: "username")
    ///       $0.set("devxoul@gmail.com", forKey: "email")
    ///       $0.synchronize()
    ///     }
    public func `do`(_ block: (Self) -> Void) {
        block(self)
    }
    
}

extension MixCompatible where Self: AnyObject {
    
    /// Makes it available to set properties with closures just after initializing.
    ///
    ///     let label = UILabel().then {
    ///       $0.textAlignment = .Center
    ///       $0.textColor = UIColor.blackColor()
    ///       $0.text = "Hello, World!"
    ///     }
    public func then(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

/// Extend NSObject with `mix` proxy.
extension NSObject: MixCompatible {}
extension CGPoint: MixCompatible {}
extension CGRect: MixCompatible {}
extension CGSize: MixCompatible {}
extension CGVector: MixCompatible {}

#if os(iOS) || os(tvOS)
    extension UIEdgeInsets: MixCompatible {}
    extension UIOffset: MixCompatible {}
    extension UIRectEdge: MixCompatible {}
#endif
