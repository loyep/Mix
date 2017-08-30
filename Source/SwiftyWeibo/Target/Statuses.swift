//
//  Statuses.swift
//  Pods
//
//  Created by Maxwell on 23/08/2017.
//
//

public extension Statuses {
    
    public var baseURL: URL {
        return URL(string: "https://api.weibo.com/2/statuses")!
    }
    
    public var path: String {
        switch self {
        case .homeTimeline:
            return "/home_timeline.json"
        }
    }
    
    public var method: SwiftyWeibo.Method { return .get }
    
    public var task: Task {
        switch self {
        case .homeTimeline(let sinceId, let maxId, let count, let page, let feature):
            return .requestParameters(parameters: [
                "since_id": (sinceId ?? 0)!,
                "max_id": (maxId ?? 0),
                "count": count ?? 0,
                "page": page,
                "feature": (feature ?? .all).rawValue
                ], encoding: URLEncoding.default)
        }
    }
}

extension Statuses: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType { return .parameter }
}
