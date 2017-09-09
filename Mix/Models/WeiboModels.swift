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
import SwiftyJSON

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
    }
    
    dynamic var id: Int64 = 0
    
    /// 微博创建时间
    dynamic var createdAt: NSDate = NSDate()
    
    /// 微博信息内容
    dynamic var text: String = ""
    
    /// 微博来源
    dynamic var source: String = ""
    
    /// 是否被截断，true：是，false：否
    dynamic var truncated = false
    
    /// 缩略图片地址，没有时不返回此字段
    dynamic var thumbnailPic: String?
    
    /// 中等尺寸图片地址，没有时不返回此字段
    dynamic var bmiddlePic: String?
    
    /// 原始图片地址，没有时不返回此字段
    dynamic var originalPic: String?
    
    /// （暂未支持）回复ID
    dynamic var inReplyToStatusId: String?
    
    /// （暂未支持）回复人UID
    dynamic var inReplyToUserId: String?
    
    /// （暂未支持）回复人昵称
    dynamic var inReplyToScreenName: String?
    
    /// 微博作者的用户信息字段
    dynamic var user: WeiboUser?
    
    /// 转发数
    dynamic var repostsCount = 0
    
    /// 评论数
    dynamic var commentsCount = 0
    
    /// 表态数
    dynamic var attitudesCount = 0
    
    /// 长文本
    dynamic var isLongText = false
    
    /// 是否已收藏，true：是，false：否
    dynamic var favorited = false
    
    /// 转发微博
    dynamic var retweetedStatus: WeiboRetweetedStatus?
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    init(_ json: JSON, isValid: Bool) {
        super.init()
        
        id = json["id"].int64Value
        
        source = (Regex(">(.+)</").firstMatch(in: json["source"].stringValue)?.captures.first ?? "")!
        text = json["text"].stringValue
        user = WeiboUser(json["user"], isValid: true)
        createdAt = json["created_at"].stringValue.date(inFormat: "EEE MMM dd HH:mm:ss Z yyyy")! as NSDate
        truncated = json["truncated"].boolValue
        thumbnailPic = json["thumbnail_pic"].string
        bmiddlePic = json["bmiddle_pic"].string
        originalPic = json["original_pic"].string
        inReplyToUserId = json["in_reply_to_user_id"].string
        inReplyToStatusId = json["in_reply_to_status_id"].string
        inReplyToScreenName = json["in_reply_to_screen_name"].string
        repostsCount = json["reposts_count"].intValue
        commentsCount = json["comments_count"].intValue
        attitudesCount = json["attitudes_count"].intValue
        
        if !json["retweeted_status"].isEmpty {
            self.retweetedStatus = WeiboRetweetedStatus(json["retweeted_status"], isValid: true)
        }
        favorited = json["favorited"].boolValue
    }
}

extension WeiboStatus {
    
    var createdDate: String? {
        let createdAt = self.createdAt as Date
        if createdAt.isToday {
            let minute = Int(Date().timeIntervalSince(createdAt) / 60)
            if minute / 60 >= 1 {
                return "\(minute / 60)小时前"
            } else if minute >= 1 {
                return "\(minute)分钟前"
            } else {
                return "刚刚"
            }
        } else if createdAt.isYesterday {
            return createdAt.string(from: "昨天 HH:mm")
        } else if createdAt.isThisYear {
            return createdAt.string(from: "MM-dd HH:mm")
        } else {
            return createdAt.string(from: "yyyy-MM-dd HH:mm")
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
    
    dynamic var id: Int64 = 0
    dynamic var cover_image_phone: String?
    dynamic var name: String?
    dynamic var screen_name: String?
    dynamic var profile_image_url: String?
    
    required init() {
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    
    init(_ json: JSON, isValid: Bool) {
        super.init()
        
        id = json["id"].int64Value
        cover_image_phone = json["cover_image_phone"].string
        profile_image_url = json["profile_image_url"].string
        screen_name = json["screen_name"].stringValue
        name = json["name"].stringValue
    }
    
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
