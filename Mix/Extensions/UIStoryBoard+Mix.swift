//
//  UIStoryBoard+Mix.swift
//  Mix
//
//  Created by Maxwell on 13/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

enum Storyboard: String {

    case main = "Main"
    case home = "Home"
    case contacts = "Contacts"
    case discover = "Discover"
    case profile = "Profile"
    case settings = "Settings"
    
    func scene<T: UIViewController>() -> T {
        guard let vc = UIStoryboard(name: self.rawValue, bundle: nil).instantiateViewController(withIdentifier: T.mix.reuseIdentifier) as? T else {
            fatalError("cannot load viewController with sbName: \(self.rawValue), id: \(T.mix.reuseIdentifier)")
        }
        return vc
    }
    
    func scene() -> UIViewController {
        guard let vc = UIStoryboard(name: self.rawValue, bundle: nil).instantiateInitialViewController() else {
            fatalError("cannot load instantiate initial viewController with sbName: \(self.rawValue)")
        }
        return vc
    }
    
}

extension UIView {
    
    public static func instantiateFromNib<T: UIView>() -> T {
        guard let view = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as? T else {
            fatalError("cannot load instantiate initial viewController with sbName: \(self)")
        }
        return view
    }
}

