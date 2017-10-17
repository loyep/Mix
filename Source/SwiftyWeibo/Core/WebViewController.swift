//
//  WebViewController.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import WebKit

final class WebViewController: UIViewController {
    
    /// retains observers
    var observers = [String: NSObjectProtocol]()
    
    var webView: WKWebView = WKWebView()
    
    var handleURL: ((_ URL: URL) -> Bool)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = webView
        webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(WebViewController.cancel(_:)))
    }
    
    @objc func cancel(_ item: UIBarButtonItem) {
        dismiss()
    }
    
    func dismiss() -> () {
        if let controller = navigationController {
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func handle(_ url: URL, _ redirectURL: URL) {
        self.handleURL = {  URL in
            if URL.absoluteString.hasPrefix(redirectURL.absoluteString) {
                return true
            }
            return false
        }
        
        Provider.main { [weak self] in
            self?.doHandle(url)
        }
        
        let key = UUID().uuidString
        
        observers[key] = Provider.notificationCenter.addObserver(
            forName: NSNotification.Name.SwiftyWeiboHandleCallbackURL,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] _ in
                guard let `self` = self else { return }
                if let observer = self.observers[key] {
                    Provider.notificationCenter.removeObserver(observer)
                    self.observers.removeValue(forKey: key)
                }
                Provider.main {
                    self.dismiss()
                }
            }
        )
    }
    
    func doHandle(_ url: URL) -> () {
        UIApplication.topViewController?.present(UINavigationController(rootViewController: self), animated: true, completion: nil)
        webView.load(URLRequest(url: url))
    }
}

/// protocol 
extension WebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let URL = navigationAction.request.url, handleURL!(URL)  else {
            decisionHandler(.allow)
            return
        }
        
        Provider.handle(url: URL)
        decisionHandler(.cancel)
    }
}

/// find the top view controller in the shared application
fileprivate extension UIApplication {
    static var topViewController: UIViewController? {
        return UIApplication.shared.topViewController
    }
    
    var topViewController: UIViewController? {
        guard let rootController = self.keyWindow?.rootViewController else {
            return nil
        }
        return UIViewController.topViewController(rootController)
    }
}

/// Load authorize url in the controller
fileprivate extension UIViewController {
    
    static func topViewController(_ viewController: UIViewController) -> UIViewController {
        guard let presentedViewController = viewController.presentedViewController else {
            return viewController
        }
        
        if let navigationController = presentedViewController as? UINavigationController {
            if let visibleViewController = navigationController.visibleViewController {
                return topViewController(visibleViewController)
            }
        } else if let tabBarController = presentedViewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return topViewController(selectedViewController)
            }
        }
        return topViewController(presentedViewController)
    }
}

