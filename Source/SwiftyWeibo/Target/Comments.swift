//
//  Comments.swift
//  Pods
//
//  Created by Maxwell on 2017/9/5.
//
//

import Foundation

public extension Comments {
    
    public var baseURL: URL {
        return URL(string: "https://api.weibo.com/2/comments")!
    }
    
    public var path: String {
        switch self {
        case .toMe:
            return "/to_me.json"
        case .byMe:
            return "/by_me.json"
        }
    }
    
    public var method: SwiftyWeibo.Method { return .get }
    
    public var task: Task {
        switch self {
        case .byMe(let sinceId, let maxId, let count, let page):
            return .requestParameters(parameters: [
                "since_id": (sinceId ?? 0)!,
                "max_id": (maxId ?? 0),
                "count": max(1, (count ?? 0)),
                "page": page,
                "filter_by_source": "0"
                ], encoding: URLEncoding.default)
        case .toMe(let sinceId, let maxId, let count, let page, let author):
            return .requestParameters(parameters: [
                "since_id": (sinceId ?? 0)!,
                "max_id": (maxId ?? 0),
                "count": max(1, (count ?? 0)),
                "page": page,
                "filter_by_author": author.rawValue,
                "filter_by_source": "0"
                ], encoding: URLEncoding.default)
        }
    }
}

extension Comments: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType { return .parameter }
}

