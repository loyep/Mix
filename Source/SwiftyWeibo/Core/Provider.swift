//
//  Provider.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

public struct ProgressResponse {
    public let response: Response?
    public let progressObject: Progress?
    
    public init(progress: Progress? = nil, response: Response? = nil) {
        self.progressObject = progress
        self.response = response
    }
    
    public var progress: Double {
        return progressObject?.fractionCompleted ?? 1.0
    }
    
    public var completed: Bool {
        return progress == 1.0 && response != nil
    }
}

public protocol ProviderType: class {
    func request(_ target: TargetType, callbackQueue: DispatchQueue?, progress: Provider.ProgressBlock?, completion: @escaping Provider.Completion) -> Cancellable
}

/// Request provider class. Requests should be made through this class only.
public class Provider: ProviderType {
    
    public let stubClosure: StubClosure = Provider.neverStub
    
    public let manager: Manager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Manager.defaultHTTPHeaders
        
        let manager = Manager(configuration: configuration)
        manager.startRequestsImmediately = false
        return manager
    }()
    
    /// The OAuth Client ID
    public let clientID: String
    
    /// The OAuth Client Secret
    public let clientSecret: String
    
    /// The access token to be applied in the header.
    public var token: Token?
    
    /// redirectURL
    public let redirectURL: URL
    
    var observer: NSObjectProtocol?
    
    public let trackInflights: Bool = true
    
    /// A list of plugins
    /// e.g. for logging, network activity indicator or credentials
    public internal(set) var plugins: [String: PluginType] = [:]
    
    public internal(set) var inflightRequests: [Endpoint<TargetType>: [Provider.Completion]] = [:]
    
    /// Propagated to Alamofire as callback queue. If nil - the Alamofire default (as of their API in 2017 - the main queue) will be used.
    public let callbackQueue: DispatchQueue? = DispatchQueue.main
    
    public static let notificationCenter: NotificationCenter = NotificationCenter.default
    
    public static let notificationQueue: OperationQueue = OperationQueue.main
    
    public let tokenStore: TokenStore
    
    /// Run block in main thread
    internal static func main(block: @escaping () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async {
                block()
            }
        }
    }
    
    fileprivate static func defaultPlugins() -> [String: PluginType] {
        var plugins: [String: PluginType] = [:]
        let logPlugin = NetworkLoggerPlugin()
        plugins.updateValue(logPlugin, forKey: logPlugin.pluginIdentifier)
        let networkActivityPlugin = NetworkActivityPlugin { activity in
            switch activity {
            case .began:
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            case .ended:
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        plugins.updateValue(networkActivityPlugin, forKey: networkActivityPlugin.pluginIdentifier)
        return plugins
    }
    
    /// Initializes a provider.
    public init(_ clientID: String,
                _ clientSecret: String,
                tokenStore: TokenStore = UserDefaults.standard,
                trackInflights: Bool = true,
                plugins: [String: PluginType] = Provider.defaultPlugins(),
                redirectURL: String = SwiftyWeiboRedirectURL) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURL = URL(string: redirectURL)!
        self.tokenStore = tokenStore
        
        self.plugins = plugins
        
        if let token = self.tokenStore.token(forProvider: self) {
            self.token = token
            let accessTokenPlugin = AccessTokenPlugin(tokenClosure: (self.token?.accessToken)!)
            self.plugins.updateValue(accessTokenPlugin, forKey: accessTokenPlugin.pluginIdentifier)
        }
    }
    
    /// Designated request-making method. Returns a `Cancellable` token to cancel the request later.
    @discardableResult
    public func request(_ target: TargetType,
                        callbackQueue: DispatchQueue? = .none,
                        progress: ProgressBlock? = .none,
                        completion: @escaping Completion) -> Cancellable {
        
        let callbackQueue = callbackQueue ?? self.callbackQueue
        return requestNormal(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    /// When overriding this method, take care to `notifyPluginsOfImpendingStub` and to perform the stub using the `createStubFunction` method.
    /// Note: this was previously in an extension, however it must be in the original class declaration to allow subclasses to override.
    @discardableResult
    public func stubRequest(_ target: TargetType, request: URLRequest, callbackQueue: DispatchQueue?, completion: @escaping Provider.Completion, endpoint: Endpoint<TargetType>, stubBehavior: SwiftyWeibo.StubBehavior) -> CancellableToken {
        let callbackQueue = callbackQueue ?? self.callbackQueue
        let cancellableToken = CancellableToken { }
        notifyPluginsOfImpendingStub(for: request, target: target)
        let plugins = self.plugins
        let stub: () -> Void = createStubFunction(cancellableToken, forTargetType: target, withCompletion: completion, endpoint: endpoint, plugins: plugins, request: request)
        switch stubBehavior {
        case .immediate:
            switch callbackQueue {
            case .none:
                stub()
            case .some(let callbackQueue):
                callbackQueue.async(execute: stub)
            }
        case .delayed(let delay):
            let killTimeOffset = Int64(CDouble(delay) * CDouble(NSEC_PER_SEC))
            let killTime = DispatchTime.now() + Double(killTimeOffset) / Double(NSEC_PER_SEC)
            (callbackQueue ?? DispatchQueue.main).asyncAfter(deadline: killTime) {
                stub()
            }
        case .never:
            fatalError("Method called to stub request when stubbing is disabled.")
        }
        
        return cancellableToken
    }
}

/// Mark: Stubbing

/// Controls how stub responses are returned.
public enum StubBehavior {
    
    /// Do not stub.
    case never
    
    /// Return a response immediately.
    case immediate
    
    /// Return a response after a delay.
    case delayed(seconds: TimeInterval)
}

public extension Provider {
    
    // Swift won't let us put the StubBehavior enum inside the provider class, so we'll
    // at least add some class functions to allow easy access to common stubbing closures.
    
    public static func neverStub(_: TargetType) -> SwiftyWeibo.StubBehavior {
        return .never
    }
    
    public static func immediatelyStub(_: TargetType) -> SwiftyWeibo.StubBehavior {
        return .immediate
    }
    
    public static func delayedStub(_ seconds: TimeInterval) -> (TargetType) -> SwiftyWeibo.StubBehavior {
        return { _ in return .delayed(seconds: seconds) }
    }
}

public extension Provider {
    
    func requestClosure(_ endpoint: Endpoint<TargetType>, _ closure: RequestResultClosure) {
        if let urlRequest = endpoint.urlRequest {
            closure(.success(urlRequest))
        } else {
            closure(.failure(SwiftyWeiboError.requestMapping(endpoint.url)))
        }
    }
    
    /// Returns an `Endpoint` based on the token, method, and parameters by invoking the `endpointClosure`.
    func endpoint(_ target: TargetType) -> Endpoint<TargetType> {
        return Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
}

