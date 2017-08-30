//
//  Common.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

extension Common: AccessTokenAuthorizable {
    
    public var authorizationType: AuthorizationType {
        switch self {
        default:
            return .parameter
        }
    }
}

public extension Common {
    
    public var baseURL: URL { return URL(string: "https://api.weibo.com/2/common")! }
    
    public var path: String {
        switch self {
        case .getTimezone:
            return "/get_timezone.json"
        case .getCountry:
            return "/get_country.json"
        case .getCity:
            return "/get_city.json"
        case .getProvince:
            return "/get_province.json"
        case .codeToLocation:
            return "/code_to_location.json"
        }
    }
    
    public var method: SwiftyWeibo.Method { return .get }
    
    public var task: Task {
        switch self {
        case .getTimezone:
            return .requestPlain
        case .getProvince(let country, let capital):
            return .requestParameters(parameters: [
                "country": country,
                "capital": capital.lowercased(),
                ], encoding: URLEncoding.default)
        case .getCity(let province, let capital):
            return .requestParameters(parameters: [
                "province": province,
                "capital": capital.lowercased(),
                ], encoding: URLEncoding.default)
        case .getCountry(let capital):
            return .requestParameters(parameters: [
                "capital": capital.lowercased(),
                ], encoding: URLEncoding.default)
        case .codeToLocation(let codes):
            return .requestParameters(parameters: [
                "codes": codes.joined(separator: ",")
                ], encoding: URLEncoding.default)
        }
    }
}
