//
//  AccessTokenPlugin.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import Result

public protocol TokenStore {
    /**
     Retrieve a token for the given Provider
     
     - parameter provider: The provider requesting the `Token`.
     
     - returns: Optional `Token`
     */
    func token(forProvider provider: SwiftyWeibo.Provider) -> SwiftyWeibo.Token?
    
    /**
     Store a token for a Provider
     
     - parameter token:   The `Token` to store.
     - parameter service: The provider requesting the `Token` storage.
     
     - returns: Void
     */
    func set(_ token: SwiftyWeibo.Token?, forProvider provider: SwiftyWeibo.Provider)
}

public extension TokenStore {
    func key(forProvider provider: SwiftyWeibo.Provider) -> String {
        return "com.maxsey.SwiftyWeibo.\(provider.clientID)"
    }
}

extension UserDefaults: TokenStore {
    public func token(forProvider provider: Provider) -> Token? {
        let key = self.key(forProvider: provider)
        
        guard let dictionary = dictionary(forKey: key) else {
            return nil
        }
        
        return Token(parameters: dictionary)
    }
    
    public func set(_ token: Token?, forProvider provider: Provider) {
        let key = self.key(forProvider: provider)
        set(token?.parameters, forKey: key)
    }
}

public struct Token {
    
    public typealias Parameters = [String: Any]
    
    public let clientID: String
    
    public let clientSecret: String
    
    public var code: String?
    
    public let expiresAt: Date
    
    public let accessToken: String
    
    public var parameters: Token.Parameters {
        var params: [String: Any] = [
            "clientID": clientID,
            "clientSecret": clientSecret,
            "expiresAt": expiresAt,
            "accessToken": accessToken
        ]
        if let code = self.code {
            params["code"] = code
        }
        return params
    }
    
    public init?(parameters: Token.Parameters) {
        guard let clientID = parameters["clientID"] as? String,
            let clientSecret = parameters["clientSecret"] as? String,
            let expiresAt = parameters["expiresAt"] as? Date,
            let accessToken = parameters["accessToken"] as? String else {
                return nil
        }
        
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.expiresAt = expiresAt
        self.accessToken = accessToken
        
        if let code = parameters["code"] as? String {
            self.code = code
        }
    }
}

// MARK: - AuthorizationType

/// An enum representing the header to use with an `AccessTokenPlugin`
public enum AuthorizationType: String {
    case none
    case parameter = "access_token"
    case basic = "Basic"
    case bearer = "Bearer"
}

// MARK: - AccessTokenAuthorizable

/// A protocol for controlling the behavior of `AccessTokenPlugin`.
public protocol AccessTokenAuthorizable {
    
    /// Represents the authorization header to use for requests.
    var authorizationType: AuthorizationType { get }
}

// MARK: - AccessTokenPlugin

/// A plugin for adding bearer-type authorization parameters to requests.
public struct AccessTokenPlugin: PluginType {
    
    public let pluginIdentifier: String = "AccessTokenPlugin"
    
    /// A closure returning the access token to be applied in the header.
    public let tokenClosure: () -> String
    
    /**
     Initialize a new `AccessTokenPlugin`.
     
     - parameters:
     - tokenClosure: A closure returning the token to be applied in the pattern `Authorization: <AuthorizationType> <token>`
     */
    public init(tokenClosure: @escaping @autoclosure () -> String) {
        self.tokenClosure = tokenClosure
    }
    
    /**
     Prepare a request by adding an authorization header if necessary.
     
     - parameters:
     - request: The request to modify.
     - target: The target of the request.
     - returns: The modified `URLRequest`.
     */
    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let authorizable = target as? AccessTokenAuthorizable else { return request }
        
        let authorizationType = authorizable.authorizationType
        
        var request = request
        
        switch authorizationType {
        case .basic, .bearer:
            let authValue = authorizationType.rawValue + " " + tokenClosure()
            request.addValue(authValue, forHTTPHeaderField: "Authorization")
        case .parameter:
            let params = [authorizationType.rawValue: tokenClosure()]
            let task = target.task
            
            switch task {
            case .requestPlain:
                if let urlRequest = try? URLEncoding.default.encode(request, with: params) {
                    request = urlRequest
                }
            case let .requestParameters(parameters, parameterEncoding):
                var requestParams: [String: String] = [:]
                requestParams.merge(parameters, params)
                if let urlRequest = try? parameterEncoding.encode(request, with: requestParams) {
                    request = urlRequest
                }
            default:
                return request
            }
        case .none:
            break
        }
        return request
    }
}
