//
//  UIViewController+Mix.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/26.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit.UIViewController

//public struct MixViewModel<Base> {
//    /// Base object to extend.
//    public let base: Base
//
//    /// Creates extensions with base object.
//    ///
//    /// - parameter base: Base object.
//    public init(_ base: Base) {
//        self.base = base
//    }
//}

/// A type that has MixCompatible extensions.
public protocol MixViewController{
    /// Extended type
    associatedtype ViewModelType
    
    /// MixReusable extensions.
    static var mix: MixTarget<ViewModelType>.Type { get }
    
    /// MixCompatible extensions.
    var mix: MixTarget<ViewModelType> { get }
}

public extension MixViewController {
    /// MixCompatible extensions.
    public static var mix: MixTarget<Self>.Type {
        get {
            return MixTarget<Self>.self
        }
    }
    
    /// MixCompatible extensions.
    public var mix: MixTarget<Self> {
        get {
            return MixTarget(self)
        }
    }
}

extension UIViewController: MixViewController { }


