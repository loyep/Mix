//
//  Cancellable.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

/// Protocol to define the opaque type returned from a request

public protocol Cancellable {
    var isCancelled: Bool { get }
    func cancel()
}

internal class CancellableWrapper: Cancellable {
    internal var innerCancellable: Cancellable = SimpleCancellable()

    var isCancelled: Bool { return innerCancellable.isCancelled }

    internal func cancel() {
        innerCancellable.cancel()
    }
}

internal class SimpleCancellable: Cancellable {
    var isCancelled = false
    func cancel() {
        isCancelled = true
    }
}
