//
//  MixRouter.swift
//  MixKit
//
//  Created by Maxwell on 2017/9/27.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
    public typealias MappingContext = Any
    public typealias NavigationContext = Any
    
    public typealias URLOpenHandler = (_ url: URLConvertible, _ values: [String: Any]) -> Bool
    
    public struct Navigation {
        public let url: URLConvertible
        
        public let values: [String: Any]
        
        public let mappingContext: MappingContext?
        
        public let navigationContext: NavigationContext?
    }
    
    public protocol URLNavigable {
        init?(navigation: Navigation)
    }
    
    internal struct URLMapItem {
        let navigable: URLNavigable.Type
        let mappingContext: MappingContext?
    }
    
    internal class MixURLRouter {
        static let `default` = MixURLRouter()
        
        internal var scheme: String? {
            didSet {
                if let scheme = self.scheme, scheme.contains("://") {
                    self.scheme = scheme.components(separatedBy: "://")[0]
                }
            }
        }
        
        fileprivate(set) var urlMap = [String: URLMapItem]()
        
        fileprivate(set) var urlOpenHandlers = [String: URLOpenHandler]()
    }
    
    public extension Mix where Base: UIApplication {
        
        private static var router: MixURLRouter {
            return MixURLRouter.default
        }
        
        // MARK: URL Mapping
        public static func map(_ urlPattern: URLConvertible, _ navigable: URLNavigable.Type, context: MappingContext? = nil) {
            let URLString = URLMatcher.default.normalized(urlPattern, scheme: router.scheme).urlStringValue
            router.urlMap[URLString] = URLMapItem(navigable: navigable, mappingContext: context)
        }
        
        public static func map(_ urlPattern: URLConvertible, _ handler: @escaping URLOpenHandler) {
            let URLString = URLMatcher.default.normalized(urlPattern, scheme: router.scheme).urlStringValue
            router.urlOpenHandlers[URLString] = handler
        }
        
        public static func viewController(for url: URLConvertible, context: NavigationContext? = nil) -> UIViewController? {
            if let urlMatchComponents = URLMatcher.default.match(url, scheme: router.scheme, from: Array(router.urlMap.keys)) {
                guard let item = MixURLRouter.default.urlMap[urlMatchComponents.pattern] else { return nil }
                let navigation = Navigation(
                    url: url,
                    values: urlMatchComponents.values,
                    mappingContext: item.mappingContext,
                    navigationContext: context
                )
                return item.navigable.init(navigation: navigation) as? UIViewController
            }
            return nil
        }
        
        // MARK: Pushing View Controllers with URL
        @discardableResult
        public static func push(
            _ url: URLConvertible,
            context: NavigationContext? = nil,
            from: UINavigationController? = nil,
            animated: Bool = true
            ) -> UIViewController? {
            guard let viewController = self.viewController(for: url, context: context) else {
                return nil
            }
            return self.push(viewController, from: from, animated: animated)
        }
        
        @discardableResult
        public static func push(
            _ viewController: UIViewController,
            from: UINavigationController? = nil,
            animated: Bool = true
            ) -> UIViewController? {
            guard let navigationController = from ??  UIViewController.mix.topVewController?.navigationController else {
                return nil
            }
            guard (viewController is UINavigationController) == false else { return nil }
            navigationController.pushViewController(viewController, animated: animated)
            return viewController
        }
        
        
        // MARK: Presenting View Controllers with URL
        @discardableResult
        public static func present(
            _ url: URLConvertible,
            context: NavigationContext? = nil,
            wrap: Bool = false,
            from: UIViewController? = nil,
            animated: Bool = true,
            completion: (() -> Void)? = nil
            ) -> UIViewController? {
            guard let viewController = self.viewController(for: url, context: context) else { return nil }
            return self.present(viewController, wrap: wrap, from: from, animated: animated, completion: completion)
        }
        
        @discardableResult
        public static func present(
            _ viewController: UIViewController,
            wrap: Bool = false,
            from: UIViewController? = nil,
            animated: Bool = true,
            completion: (() -> Void)? = nil
            ) -> UIViewController? {
            guard let fromViewController = from ?? UIViewController.mix.topVewController else { return nil }
            let wrap = wrap && (viewController is UINavigationController) == false
            if wrap {
                let navigationController = UINavigationController(rootViewController: viewController)
                fromViewController.present(navigationController, animated: animated, completion: nil)
            } else {
                fromViewController.present(viewController, animated: animated, completion: nil)
            }
            return viewController
        }
        
        
        // MARK: Opening URL
        @discardableResult
        public static func open(_ url: URLConvertible) -> Bool {
            let urlOpenHandlersKeys = Array(MixURLRouter.default.urlOpenHandlers.keys)
            if let urlMatchComponents = URLMatcher.default.match(url, scheme: router.scheme, from: urlOpenHandlersKeys) {
                let handler = router.urlOpenHandlers[urlMatchComponents.pattern]
                if handler?(url, urlMatchComponents.values) == true {
                    return true
                }
            }
            return false
        }
    }
    
    public struct URLMatchComponents {
        public let pattern: String
        public let values: [String: Any]
    }
    
    open class URLMatcher {
        
        public typealias URLValueMatcherHandler = (String) -> Any?
        
        private var customURLValueMatcherHandlers = [String: URLValueMatcherHandler]()
        
        
        // MARK: Singleton
        
        open static let `default` = URLMatcher()
        
        
        // MARK: Initialization
        
        public init() {
            // 🔄 I'm a URLMatcher!
        }
        
        
        // MARK: Matching
        open func match(_ url: URLConvertible, scheme: String? = nil, from urlPatterns: [String]) -> URLMatchComponents? {
            let normalizedURLString = self.normalized(url, scheme: scheme).urlStringValue
            let urlPathComponents = normalizedURLString.components(separatedBy: "/") // e.g. ["myapp:", "user", "123"]
            
            outer: for urlPattern in urlPatterns {
                // e.g. ["myapp:", "user", "<int:id>"]
                let urlPatternPathComponents = urlPattern.components(separatedBy: "/")
                let containsPathPlaceholder = urlPatternPathComponents.contains { $0.hasPrefix("<path:") }
                guard containsPathPlaceholder || urlPatternPathComponents.count == urlPathComponents.count else {
                    continue
                }
                
                var values = [String: Any]()
                
                // e.g. ["user", "<int:id>"]
                for (i, component) in urlPatternPathComponents.enumerated() {
                    guard i < urlPathComponents.count else {
                        continue outer
                    }
                    let info = self.placeholderKeyValueFrom(urlPatternPathComponent: component,
                                                            urlPathComponents: urlPathComponents,
                                                            atIndex: i)
                    if let (key, value) = info {
                        values[key] = value // e.g. ["id": 123]
                        if component.hasPrefix("<path:") {
                            break // there's no more placeholder after <path:>
                        }
                    } else if component != urlPathComponents[i] {
                        continue outer
                    }
                }
                
                return URLMatchComponents(pattern: urlPattern, values: values)
            }
            return nil
        }
        
        // MARK: Utils
        open func addURLValueMatcherHandler(for valueType: String, handler: @escaping URLValueMatcherHandler) {
            self.customURLValueMatcherHandlers[valueType] = handler
        }
        
        func url(withScheme scheme: String?, _ url: URLConvertible) -> URLConvertible {
            let urlString = url.urlStringValue
            if let scheme = scheme, !urlString.contains("://") {
                #if DEBUG
                    if !urlString.hasPrefix("/") {
                        NSLog("[Warning] URL pattern doesn't have leading slash(/): '\(url)'")
                    }
                #endif
                return scheme + ":/" + urlString
            } else if scheme == nil && !urlString.contains("://") {
                assertionFailure("Either matcher or URL should have scheme: '\(url)'") // assert only in debug build
            }
            return urlString
        }
        
        func normalized(_ dirtyURL: URLConvertible, scheme: String? = nil) -> URLConvertible {
            guard dirtyURL.urlValue != nil else {
                return dirtyURL
            }
            var urlString = self.url(withScheme: scheme, dirtyURL).urlStringValue
            urlString = urlString.components(separatedBy: "?")[0].components(separatedBy: "#")[0]
            urlString = self.replaceRegex(":/{3,}", "://", urlString)
            urlString = self.replaceRegex("(?<!:)/{2,}", "/", urlString)
            urlString = self.replaceRegex("(?<!:|:/)/+$", "", urlString)
            return urlString
        }
        
        func placeholderKeyValueFrom(
            urlPatternPathComponent component: String,
            urlPathComponents: [String],
            atIndex index: Int
            ) -> (String, Any)? {
            guard component.hasPrefix("<") && component.hasSuffix(">") else { return nil }
            
            let start = component.index(after: component.startIndex)
            let end = component.index(before: component.endIndex)
            let placeholder = component[start..<end] // e.g. "<int:id>" -> "int:id"
            
            let typeAndKey = placeholder.components(separatedBy: ":") // e.g. ["int", "id"]
            if typeAndKey.count == 0 { // e.g. component is "<>"
                return nil
            }
            if typeAndKey.count == 1 { // untyped placeholder
                return (String(placeholder) , urlPathComponents[index])
            }
            
            let (type, key) = (typeAndKey[0], typeAndKey[1]) // e.g. ("int", "id")
            let value: Any?
            switch type {
            case "UUID": value = UUID(uuidString: urlPathComponents[index]) // e.g. 123e4567-e89b-12d3-a456-426655440000
            case "string": value = String(urlPathComponents[index]) // e.g. "123"
            case "int": value = Int(urlPathComponents[index]) // e.g. 123
            case "float": value = Float(urlPathComponents[index]) // e.g. 123.0
            case "path": value = urlPathComponents[index..<urlPathComponents.count].joined(separator: "/")
            default:
                if let customURLValueTypeHandler = customURLValueMatcherHandlers[type] {
                    value = customURLValueTypeHandler(urlPathComponents[index])
                }
                else {
                    value = urlPathComponents[index]
                }
            }
            
            if let value = value {
                return (key, value)
            }
            return nil
        }
        
        func replaceRegex(_ pattern: String, _ repl: String, _ string: String) -> String {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return string }
            let range = NSMakeRange(0, string.characters.count)
            return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: repl)
        }
    }
    
#endif
