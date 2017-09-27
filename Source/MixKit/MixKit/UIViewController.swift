//
//  UIViewController.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation

public extension Mix where Base: UIViewController {
    
    public func bind() -> () {
        print(String(describing: base))
    }
}
