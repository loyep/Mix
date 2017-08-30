//
//  PluginType.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import Result

/// A Moya Plugin receives callbacks to perform side effects wherever a request is sent or received.
///
/// for example, a plugin may be used to
///     - log network requests
///     - hide and show a network activity indicator
///     - inject additional information into a request
public protocol PluginType {
    /// The Unique identifier for this plugin.
    var pluginIdentifier: String { get }
    
    /// Called to modify a request before sending
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest
    
    /// Called immediately before a request is sent over the network (or stubbed).
    func willSend(_ request: RequestType, target: TargetType)
    
    /// Called after a response has been received, but before the MoyaProvider has invoked its completion handler.
    func didReceive(_ result: Result<SwiftyWeibo.Response, SwiftyWeiboError>, target: TargetType)
    
    /// Called to modify a result before completion
    func process(_ result: Result<SwiftyWeibo.Response, SwiftyWeiboError>, target: TargetType) -> Result<SwiftyWeibo.Response, SwiftyWeiboError>
}

public extension PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest { return request }
    func willSend(_ request: RequestType, target: TargetType) { }
    func didReceive(_ result: Result<SwiftyWeibo.Response, SwiftyWeiboError>, target: TargetType) { }
    func process(_ result: Result<SwiftyWeibo.Response, SwiftyWeiboError>, target: TargetType) -> Result<SwiftyWeibo.Response, SwiftyWeiboError> { return result }
}

/// Request type used by `willSend` plugin function.
public protocol RequestType {
    
    // Note:
    //
    // We use this protocol instead of the Alamofire request to avoid leaking that abstraction.
    // A plugin should not know about Alamofire at all.
    
    /// Retrieve an `NSURLRequest` representation.
    var request: URLRequest? { get }
}
