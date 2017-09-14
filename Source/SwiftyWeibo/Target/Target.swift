//
//  Target.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

public enum HomeTimeLineFeature: Int {
    case all = 0
    case original = 1
    case image = 2
    case video = 3
    case music = 4
}

public enum OAuth2: TargetType {
    case authorize(config: Provider, scopes: [String], state: String)
    case accessToken(Provider, code: String)
    case getTokenInfo
}

public enum Account: TargetType {
    case rateLimitStatus
    case getUid
    case profileEmail
}

public enum Common: TargetType {
    case getCountry(capital: String)
    case getCity(province: String, capital: String)
    case getProvince(country: String, capital: String)
    case getTimezone
    case codeToLocation(codes: [String])
}

public enum Statuses: TargetType {
    case homeTimeline(sinceId: Int64?, maxId: Int64?, count: Int?, page: Int, feature: HomeTimeLineFeature?)
    case favorites(count: Int?, page: Int)
}

public enum CommentAuthor: Int {
    case all = 0
    case follow = 1
    case stranger = 2
}

public enum Comments: TargetType {
    case byMe(sinceId: Int?, maxId: Int?, count: Int?, page: Int)
    case toMe(sinceId: Int?, maxId: Int?, count: Int?, page: Int, author: CommentAuthor)
}
