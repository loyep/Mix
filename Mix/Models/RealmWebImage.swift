//
//  RealmWebImage.swift
//  Mix
//
//  Created by Maxwell on 2017/9/2.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import Foundation
import RealmSwift

internal class RealmWebImage: Object {
    
    @objc internal override static func primaryKey() -> String? {
        return "cacheImageUrl"
    }
    
    dynamic var cacheImageUrl: String = ""
    
    dynamic var webCacheData = NSData()
    
    dynamic var webCacheSize: Int = 0
}

internal class RealmWebImageCache {
    internal static let shared = RealmWebImageCache()
    
    internal typealias Completion = (_ image: UIImage?, _ error: Error?) -> Void
    
    var inflightRequests: [URL: [RealmWebImageCache.Completion]] = [:]
    
    func loadCacheImage(url: URL, completion: @escaping RealmWebImageCache.Completion) -> Void {
        guard let realm = try? Realm() else {
            return
        }
        
        if let webData = realm.object(ofType: RealmWebImage.self, forPrimaryKey: url.absoluteString)?.webCacheData {
            return completion(UIImage(data: webData as Data), nil)
        }
        
        objc_sync_enter(self)
        var inflightCompletionBlocks = self.inflightRequests[url]
        inflightCompletionBlocks?.append(completion)
        self.inflightRequests[url] = inflightCompletionBlocks
        objc_sync_exit(self)
        
        if inflightCompletionBlocks != nil {
            return
        } else {
            objc_sync_enter(self)
            self.inflightRequests[url] = [completion]
            objc_sync_exit(self)
        }
        
        let networkCompletion: RealmWebImageCache.Completion = { [weak self] image, error in
            self?.inflightRequests[url]?.forEach { $0(image, error) }
            objc_sync_enter(self)
            self?.inflightRequests.removeValue(forKey: url)
            objc_sync_exit(self)
        }
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: url) else {
                networkCompletion(nil, NSError(domain: "", code: 403, userInfo: nil))
                return
            }
            
            DispatchQueue.main.async {
                guard let realm = try? Realm() else {
                    networkCompletion(nil, NSError(domain: "", code: 403, userInfo: nil))
                    return
                }
                
                SafeDispatch.async(forWork: {
                    try? realm.write {
                        let webCache = RealmWebImage()
                        webCache.cacheImageUrl = url.absoluteString
                        webCache.webCacheData = imageData as NSData
                        webCache.webCacheSize = imageData.count
                        realm.add(webCache, update: true)
                    }
                })
                networkCompletion(UIImage(data: imageData), nil)
            }
        }
    }
}

public extension UIImageView {
    public func mix_setImage(_ imageUrl: URL, placeHolder: UIImage?) {
        self.image = placeHolder
        RealmWebImageCache.shared.loadCacheImage(url: imageUrl) { [weak self] image, error in
            if let this = self, let image = image {
                this.image = image
            }
        }
    }
}

public extension UIButton {
    public func mix_setImage(_ imageUrl: URL, placeHolder: UIImage?, for state: UIControlState) {
        setImage(placeHolder, for: state)
        RealmWebImageCache.shared.loadCacheImage(url: imageUrl) { [weak self] image, error in
            if let this = self, let image = image {
                this.setImage(image, for: state)
            }
        }
    }
}
