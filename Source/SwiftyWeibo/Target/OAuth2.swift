//
//  OAuth2.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

public extension OAuth2 {
    
    public var baseURL: URL {
        return URL(string: "https://api.weibo.com/oauth2")!
    }
    
    public var path: String {
        switch self {
        case .authorize:
            return "/authorize"
        case .accessToken:
            return "/access_token"
        case .getTokenInfo:
            return "/get_token_info"
        }
    }
    
    public var method: SwiftyWeibo.Method {
        switch self {
        case .authorize:
            return .get
        case .accessToken, .getTokenInfo:
            return .post
        }
    }
    
    public var task: Task {
        switch self {
        case .authorize(let config, scopes: let scopes, state: let state):
            return .requestParameters(parameters: [
                "client_id": config.clientID,
                "client_secret": config.clientSecret,
                "redirect_uri": config.redirectURL.absoluteString,
                "scope": scopes.joined(separator: ","),
                "state": state
                ], encoding: URLEncoding.default)
        case .accessToken(let config, code: let code):
            return .requestParameters(parameters: [
                "client_id": config.clientID,
                "client_secret": config.clientSecret,
                "redirect_uri": config.redirectURL.absoluteString,
                "grant_type": "authorization_code",
                "code": code
                ], encoding: URLEncoding.default)
        default :
            return .requestPlain
        }
    }
}

extension OAuth2: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType {
        switch self {
        case .getTokenInfo:
            return .parameter
        default:
            return .none
        }
    }
}

public extension Account {
    
    public var baseURL: URL { return URL(string: "https://api.weibo.com/account")! }
    
    public var path: String {
        switch self {
        case .getUid:
            return "/get_uid.json"
        case .rateLimitStatus:
            return "/rate_limit_status.json"
        case .profileEmail:
            return "/profile/email.json"
        }
    }
    
    public var method: SwiftyWeibo.Method { return .get }
    
    public var task: Task { return .requestPlain }
}

extension Account: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType {
        return .parameter
    }
}
