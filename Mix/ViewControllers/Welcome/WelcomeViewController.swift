//
//  WelcomeViewController.swift
//  Mix
//
//  Created by Maxwell on 31/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyWeibo

fileprivate struct WelcomeViewControllerUX {
    static let WeiboLoginButtonSize = CGSize(width: 300, height: 60)
}

class WelcomeViewController: UIViewController {
    
    fileprivate lazy var weiboLoginButton: UIButton = {
        let weiboLoginButton = UIButton(type: .custom)
        weiboLoginButton.setTitle("注册", for: .normal)
        weiboLoginButton.addTarget(self, action: #selector(self.weiboLogin), for: .touchUpInside)
        weiboLoginButton.backgroundColor = UIColor.cyan
        return weiboLoginButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(weiboLoginButton)
        weiboLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(WelcomeViewControllerUX.WeiboLoginButtonSize)
        }
    }
    
    @objc fileprivate func weiboLogin() -> () {
        if WeiboSDK.isCanSSOInWeiboApp() {
            let authRequest = WBAuthorizeRequest.request() as? WBAuthorizeRequest
            authRequest?.redirectURI = SwiftyWeibo.SwiftyWeiboRedirectURL
            WeiboSDK.send(authRequest)
        } else {
            weibo.authorize(completion: { result in
                switch result {
                case .success:
//                    this.dismiss(animated: true, completion: nil)
                    UIApplication.shared.keyWindow?.rootViewController = NavigationController(rootViewController: TabBarController())
                case .failure:
                    print("fail")
                }
            })
        }
    }
    
}
