//
//  UIViewController+Mix.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/26.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit.UIViewController

public struct MixViewModel<Base> {
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
public protocol MixViewController{
    /// Extended type
    associatedtype ViewModelType
    
    /// MixReusable extensions.
    static var mix: MixViewModel<ViewModelType>.Type { get }
    
    /// MixCompatible extensions.
    var mix: MixViewModel<ViewModelType> { get }
}

public extension MixViewController {
    /// MixCompatible extensions.
    public static var mix: MixViewModel<Self>.Type {
        get {
            return MixViewModel<Self>.self
        }
    }
    
    /// MixCompatible extensions.
    public var mix: MixViewModel<Self> {
        get {
            return MixViewModel(self)
        }
    }
}

extension UIViewController: MixViewController { }


