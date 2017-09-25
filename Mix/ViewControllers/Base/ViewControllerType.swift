//
//  ViewControllerType.swift
//  Mix
//
//  Created by Maxwell on 2017/9/25.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation

public protocol ViewControllerType: NSObjectProtocol {

    func `init`(_ viewModel: ViewModelType)
}

public protocol TableViewControllerType: ViewControllerType {
    
}

public protocol CollectionViewControllerType: ViewControllerType {
    
}

public protocol WebViewControllerType: ViewControllerType {
    
}
