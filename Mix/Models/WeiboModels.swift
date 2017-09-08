//
//  WeiboModels.swift
//  Mix
//
//  Created by Maxwell on 01/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import YYText

class WeiboHomeLine: Object {
    
    @objc override static func primaryKey() -> String? {
        return "since_id"
    }
    
    dynamic var since_id: Int64 = 0
    dynamic var max_id: Int64 = 0
    dynamic var total_number = 0
    
    let statuses = List<WeiboStatus>()
    
}

class WeiboStatus: Object {
    
    @objc override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc override static func ignoredProperties() -> [String] {
        return ["yyTextLayout"]
        //        return []
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
        print("\(1)")
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        super.init()
        print("\(3)")
    }
    
    dynamic var id: Int64 = 0
    
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
    
    var textAttr: NSData? = nil
    
    var yyTextLayout: YYTextLayout? {
        let attr = NSMutableAttributedString(string: self.text,
                                             attributes: [
                                                NSFontAttributeName: Theme.font,
                                                NSParagraphStyleAttributeName: Theme.paragraph,
                                                ])//.addLinks().replaceEmotion().replaceFullText()
        
        let container = YYTextContainer(size: CGSize(width: UIScreen.main.bounds.size.width - 20, height: CGFloat(MAXFLOAT)), insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        
        let layout = YYTextLayout(container: container, text: attr)!
        return layout
    }
}

extension WeiboStatus {
    
    var createdDate: String? {
        guard let createdDate = self.created_at?.date(inFormat: "EEE MMM dd HH:mm:ss Z yyyy") else {
            return nil
        }
        
        if createdDate.isToday {
            if createdDate.hour >= 1 {
                return "\(createdDate.hour)小时前"
            } else if createdDate.minute >= 1 {
                return "\(createdDate.minute)分钟前"
            } else {
                return "刚刚"
            }
        } else if createdDate.isYesterday {
            return createdDate.string(from: "昨天 HH:mm")
        } else if createdDate.isThisYear {
            return createdDate.string(from: "MM-dd HH:mm")
        } else {
            return createdDate.string(from: "yyyy-MM-dd HH:mm")
        }
    }
    
    var sourceName: String {
        return try! NSAttributedString(data: source.data(using: .unicode)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil).string
    }
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
        return Regex("([https]+://[^\\s]*)")
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
