//
//  UserDefaultsKey.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

struct UserDefaultsKey<T> {
    typealias Key<T> = UserDefaultsKey<T>
    let key: String
}

extension UserDefaultsKey: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(key: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(key: value)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(key: value)
    }
}
