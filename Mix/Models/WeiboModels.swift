//
//  WeiboModels.swift
//  Mix
//
//  Created by Maxwell on 01/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import RealmSwift
import YYText

class WeiboHomeLine: Object {
    
    @objc override static func primaryKey() -> String? {
        return "since_id"
    }
    
    dynamic var since_id = 0
    dynamic var max_id = 0
    dynamic var total_number = 0
    
    let statuses = List<WeiboStatus>()
    
}

class WeiboStatus: Object {
    
    @objc override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc override static func ignoredProperties() -> [String] {
        return ["yyTextLayout"]
    }
    
    dynamic var id = 0
    
    /// 微博创建时间
    dynamic var created_at: String?
    
    /// 微博信息内容
    dynamic var text: String = ""
    
    dynamic var source_type = 0
    
    /// 微博来源
    dynamic var source: String = ""
    
    /// 是否被截断，true：是，false：否
    dynamic var truncated = false
    
    /// 缩略图片地址，没有时不返回此字段
    dynamic var thumbnail_pic: String?
    
    /// 中等尺寸图片地址，没有时不返回此字段
    dynamic var bmiddle_pic: String?
    
    /// 原始图片地址，没有时不返回此字段
    dynamic var original_pic: String?
    
    /// （暂未支持）回复ID
    dynamic var in_reply_to_status_id: String?
    
    /// （暂未支持）回复人UID
    dynamic var in_reply_to_user_id: String?
    
    /// （暂未支持）回复人昵称
    dynamic var in_reply_to_screen_name: String?
    
    /// 微博作者的用户信息字段
    dynamic var user: WeiboUser?
    
    /// 转发数
    dynamic var reposts_count = 0
    
    /// 评论数
    dynamic var comments_count = 0
    
    /// 表态数
    dynamic var attitudes_count = 0
    
    /// 长文本
    dynamic var isLongText = false
    
    /// 是否已收藏，true：是，false：否
    dynamic var favorited = false
    
    /// 转发微博
    dynamic var retweeted_status: WeiboRetweetedStatus?
    
    dynamic var yyTextLayoutArchive: NSData? = nil
    
    lazy var yyTextLayout: YYTextLayout? = {
        if let layoutArchive = self.yyTextLayoutArchive, let layout = (NSKeyedUnarchiver.unarchiveObject(with: layoutArchive as Data) as? YYTextLayout) {
            print("archived: \(self.text)")
            return layout
        }
        
        let attr = NSMutableAttributedString(string: self.text, attributes: [NSFontAttributeName: Theme.font]).addLinks().replaceEmotion().replaceFullText()
        let layout = YYTextLayout(containerSize: CGSize(width: UIScreen.main.bounds.size.width - 80, height: CGFloat(MAXFLOAT)), text: attr)!
        SafeDispatch.async(forWork: {
            guard let realm = try? Realm() else {
                return
            }
            
            try? realm.write {
                print("archiveing: \(self.text)")
                let archiveData = NSKeyedArchiver.archivedData(withRootObject: layout) as NSData
                self.yyTextLayoutArchive = archiveData
            }
        })
        print("unarchive: \(self.text)")
        return layout
    }()
}

class WeiboRetweetedStatus: WeiboStatus {
    
}


class WeiboUser: Object {
    
    @objc override static func primaryKey() -> String? {
        return "id"
    }
    
    dynamic var id = 0
    dynamic var cover_image_phone: String?
    dynamic var name: String?
    dynamic var screen_name: String?
    dynamic var profile_image_url: String?
    
}

extension Regex {
    
    static var fullTextRegex: Regex = {
        return Regex("(\\u5168\\u6587)： ([a-zA-z]+://[^\\s]*)")
    }()
    
    static var linkTextRegex: Regex = {
        return Regex("([a-zA-z]+://[^\\s]*)")
    }()
    
    static var emotions: [[String: String]] = {
        guard let url = Bundle.main.path(forResource:"emoticons", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: url)),
            let json = try? JSONSerialization.jsonObject(with:data, options:JSONSerialization.ReadingOptions.mutableContainers) as! [[String: String]] else {
                return []
        }
        
        return json
    }()
    
    static var emotionRegex: Regex = {
        return Regex("(\\[+[\\u2e80-\\u9fff]{1,2}+\\])")
    }()
}
