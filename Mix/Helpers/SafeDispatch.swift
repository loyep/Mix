//
//  SafeDispatch.swift
//  Mix
//
//  Created by Maxwell on 24/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

open class SafeDispatch {
    
    fileprivate let mainQueueKey = DispatchSpecificKey<UInt8>()
    fileprivate let mainQueueValue = UInt8.max
    
    fileprivate static let sharedSafeDispatch = SafeDispatch()
    
    fileprivate init() {
        DispatchQueue.main.setSpecific(key: mainQueueKey, value: mainQueueValue)
    }
    
    open static func async(onQueue queue: DispatchQueue = DispatchQueue.main, forWork block: @escaping ()->()) {
        if queue === DispatchQueue.main {
            if DispatchQueue.getSpecific(key: sharedSafeDispatch.mainQueueKey) == sharedSafeDispatch.mainQueueValue {
                block()
            } else {
                DispatchQueue.main.async {
                    block()
                }
            }
        } else {
            queue.async {
                block()
            }
        }
    }
}
