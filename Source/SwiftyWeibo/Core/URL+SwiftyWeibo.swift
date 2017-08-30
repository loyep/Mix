//
//  URL+SwiftyWeibo.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

public extension URL {

    /// Initialize URL from SwiftyWeibo's `TargetType`.
    init(target: TargetType) {
        // When a TargetType's path is empty, URL.appendingPathComponent may introduce trailing /, which may not be wanted in some cases
        if target.path.isEmpty {
            self = target.baseURL
        } else {
            self = target.baseURL.appendingPathComponent(target.path)
        }
    }
    
    var fragments: [String: String] {
        var result: [String: String] = [:]
        
        guard let fragment = self.fragment else { return result }
        
        for pair in fragment.components(separatedBy: "&") {
            let pair = pair.components(separatedBy: "=")
            if pair.count == 2 { result[pair[0]] = pair[1] }
        }
        
        return result
    }
    
    var queries: [String: String] {
        var result: [String: String] = [:]
        
        for item in queryItems {
            result[item.name] = item.value
        }
        
        return result
    }
    
    func queries(_ items: [String: String]) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        
        components?.queryItems = items.map { (name, value) in
            return URLQueryItem(name: name, value: value)
        }
        
        return components?.url ?? self
    }
    
    fileprivate var queryItems: [URLQueryItem] {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems ?? []
    }
    
}

// MARK: - Dictionary

internal extension Dictionary {
    
    mutating func merge<K, V>(_ dictionaries: Dictionary<K, V>...) {
        for dict in dictionaries {
            for (key, value) in dict {
                if let v = value as? Value, let k = key as? Key {
                    self.updateValue(v, forKey: k)
                }
            }
        }
    }
}
