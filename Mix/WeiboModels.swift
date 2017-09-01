//
//  WeiboModels.swift
//  Mix
//
//  Created by Maxwell on 01/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import RealmSwift

class WeiboStatus: Object {
    
    @objc override static func primaryKey() -> String? {
        return "id"
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
