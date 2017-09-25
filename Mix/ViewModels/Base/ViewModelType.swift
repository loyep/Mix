//
//  ViewModelType.swift
//  Mix
//
//  Created by Maxwell on 22/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

public protocol ViewModelType {

    static var mix_viewModelName: String { get }
}

public protocol TableViewModelType: ViewModelType {
    
    func reloadData()
}

public protocol CollectionViewModelType: ViewModelType {
    
    func reloadData()
}

extension ViewModelType {
    
    public static var mix_viewModelName: String {
        return String(describing: self)
    }
    
}
