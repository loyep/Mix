//
//  WeiboStatusLayout.swift
//  Mix
//
//  Created by Maxwell on 2017/9/16.
//  Copyright © 2017年 Maxsey Inc. All rights reserved.
//

import UIKit
import YYKit

enum WBStatusTagType: Int {
    case none   //没Tag
    case normal //文本
    case place  //地点
}

enum WeiboStatusCardType: Int {
    case none = 0
    case normal
    case video
}

struct WeiboStatusLayoutConfig {
    /// cell 顶部灰色留白
    static let kWBCellTopMargin = CGFloat(8)
    /// cell 标题高度 (例如"仅自己可见")
    static let kWBCellTitleHeight = CGFloat(36)
    /// cell 内边距
    static let kWBCellPadding = CGFloat(12)
    /// cell 文本与其他元素间留白
    static let kWBCellPaddingText = CGFloat(10)
    /// cell 多张图片中间留白
    static let kWBCellPaddingPic = CGFloat(4)
    /// cell 名片高度
    static let kWBCellProfileHeight = CGFloat(56)
    /// cell card 视图高度
    static let kWBCellCardHeight = CGFloat(70)
    /// cell 名字和 avatar 之间留白
    static let kWBCellNamePaddingLeft = CGFloat(14)
    /// cell 内容宽度
    static var kWBCellContentWidth: CGFloat {
        return UIScreen.main.bounds.width - 2 * kWBCellPadding
    }
    /// cell 名字最宽限制
    static let kWBCellNameWidth = UIScreen.main.bounds.width - 110
    /// tag 上下留白
    static var kWBCellTagPadding = CGFloat(8)
    /// 一般 tag 高度
    static var kWBCellTagNormalHeight = CGFloat(16)
    /// 地理位置 tag 高度
    static var kWBCellTagPlaceHeight = CGFloat(24)
    /// cell 下方工具栏高度
    static var kWBCellToolbarHeight = CGFloat(35)
    /// cell 下方灰色留白
    static var kWBCellToolbarBottomMargin = CGFloat(2)
    /// 名字字体大小
    static var kWBCellNameFontSize = 16
    /// 来源字体大小
    static var kWBCellSourceFontSize = 12
    /// 文本字体大小
    static var kWBCellTextFontSize = 17
    /// 转发字体大小
    static var kWBCellTextFontRetweetSize = 16
    /// 卡片标题文本字体大小
    static var kWBCellCardTitleFontSize = 16
    /// 卡片描述文本字体大小
    static var kWBCellCardDescFontSize = 12
    /// 标题栏字体大小
    static var kWBCellTitlebarFontSize = 14
    /// 工具栏字体大小
    static var kWBCellToolbarFontSize = 14
    /// 名字颜色
    static var kWBCellNameNormalColor = UIColor(rgba: 0x333333)
    /// 橙名颜色 (VIP)
    static var kWBCellNameOrangeColor = UIColor(rgba: 0xf26220)
    /// 时间颜色
    static var kWBCellTimeNormalColor = UIColor(rgba: 0x828282)
    /// 橙色时间 (最新刷出)
    static var kWBCellTimeOrangeColor = UIColor(rgba: 0xf28824)
    /// 一般文本色
    static var kWBCellTextNormalColor = UIColor(rgba: 0x333333)
    /// 次要文本色
    static var kWBCellTextSubTitleColor = UIColor(rgba: 0x5d5d5d)
    /// Link 文本色
    static var kWBCellTextHighlightColor = UIColor(rgba: 0x527ead)
    /// Link 点击背景色
    static var kWBCellTextHighlightBackgroundColor = UIColor(rgba: 0xbfdffe)
    /// 工具栏文本色
    static var kWBCellToolbarTitleColor = UIColor(rgba: 0x929292)
    /// 工具栏文本高亮色
    static var kWBCellToolbarTitleHighlightColor = UIColor(rgba: 0xdf422d)
    /// Cell背景灰色
    static var kWBCellBackgroundColor = UIColor(rgba: 0xf2f2f2)
    /// Cell高亮时灰色
    static var kWBCellHighlightColor = UIColor(rgba: 0xf0f0f0)
    /// Cell内部卡片灰色
    static var kWBCellInnerViewColor = UIColor(rgba: 0xf7f7f7)
    /// Cell内部卡片高亮时灰色
    static var kWBCellInnerViewHighlightColor = UIColor(rgba: 0xf0f0f0)
    /// 线条颜色
    static var kWBCellLineColor = UIColor(white: 0.000, alpha: 0.09)
    /// NSString
    static var kWBLinkHrefName = "href"
    /// WBURL
    static var kWBLinkURLName = "url"
    /// WBTag
    static var kWBLinkTagName = "tag"
    /// WBTopic
    static var kWBLinkTopicName = "topic"
    /// NSString
    static var kWBLinkAtName = "at"
}

/// WeiboStatusLayout
class WeiboStatusLayout: NSObject {
    
    // MARK: 顶部留白
    /// 顶部灰色留白
    var marginTop: CGFloat = 0
    /// 标题栏高度，0为没标题栏
    var titleHeight: CGFloat = 0
    /// 标题栏
    var titleTextLayout: YYTextLayout?
    
    // MARK: 个人资料
    /// 个人资料高度(包括留白)
    var profileHeight: CGFloat = 0
    /// 名字
    var nameTextLayout: YYTextLayout?
    /// 时间/来源
    var sourceTextLayout: YYTextLayout?
    
    // MARK: 文本
    /// 文本高度(包括下方留白)
    var textHeight: CGFloat = 0
    var textLayout: YYTextLayout?
    
    // MARK: 图片
    /// 图片高度，0为没图片
    var picHeight: CGFloat = 0
    /// 图片大小
    var picSize: CGSize = .zero
    
    // MARK: 转发
    /// 转发高度，0为没转发
    var retweetHeight: CGFloat = 0
    var retweetTextHeight: CGFloat = 0
    var retweetTextLayout: YYTextLayout?
    var retweetPicHeight: CGFloat = 0
    var retweetPicSize: CGSize = .zero
    var retweetCardHeight: CGFloat = 0
    var retweetCardType: WeiboStatusCardType = .none
    var retweetCardTextLayout: YYTextLayout?
    var retweetCardTextRect: CGRect = .zero
    
    // MARK: 卡片
    /// 卡片高度，0为没卡片
    var cardHeight: CGFloat = 0
    var cardType: WeiboStatusCardType = .none
    /// 卡片文本
    var cardTextLayout: YYTextLayout?
    var cardTextRect: CGRect = .zero
    
    // MARK: Tag
    /// Tip高度，0为没tip
    var tagHeight = CGFloat(0)
    ///最下方tag
    var tagTextLayout: YYTextLayout?
    
    // MARK: Tool
    /// 工具栏
    var toolbarHeight = CGFloat(0)
    var toolbarRepostTextLayout: YYTextLayout?
    var toolbarCommentTextLayout: YYTextLayout?
    var toolbarLikeTextLayout: YYTextLayout?
    var toolbarRepostTextWidth = CGFloat(0)
    var toolbarCommentTextWidth = CGFloat(0)
    var toolbarLikeTextWidth = CGFloat(0)
    
    // MARK: 下边留白
    var marginBottom = CGFloat(0)
    
    // MARK: 总高度
    var height = CGFloat(0)
    
    fileprivate(set) var status: WeiboStatus?
    
    func bind(for viewModel: WeiboStatus) -> () {
        status = viewModel.copy() as? WeiboStatus
    }
    
    func updateDate() {
        
    }
    
    func layoutTitle() {
        titleHeight = 0
        titleTextLayout = nil
        
//        _titleHeight = 0;
//        _titleTextLayout = nil;
//
//        WBStatusTitle *title = _status.title;
//        if (title.text.length == 0) return;
//
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:title.text];
//        if (title.iconURL) {
//            NSAttributedString *icon = [self _attachmentWithFontSize:kWBCellTitlebarFontSize imageURL:title.iconURL shrink:NO];
//            if (icon) {
//                [text insertAttributedString:icon atIndex:0];
//            }
//        }
//        text.color = kWBCellToolbarTitleColor;
//        text.font = [UIFont systemFontOfSize:kWBCellTitlebarFontSize];
//
//        YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(kScreenWidth - 100, kWBCellTitleHeight)];
//        _titleTextLayout = [YYTextLayout layoutWithContainer:container text:text];
//        _titleHeight = kWBCellTitleHeight;
    }
    
    func layoutProfile() {
        
    }
    
    func layoutRetweet() {
        
    }
    
    func layoutPics() {
        
    }
    
    func layoutCard() {
        
    }
    
    func layoutText() {
        
    }
    
    func layoutTag() {
        
    }
    
    func layoutToolbar() {
        
    }
    
    func layout() {
        marginTop =  WeiboStatusLayoutConfig.kWBCellTopMargin;
        toolbarHeight = WeiboStatusLayoutConfig.kWBCellToolbarHeight;
        marginBottom = WeiboStatusLayoutConfig.kWBCellToolbarBottomMargin;
        
        layoutTitle()
        layoutProfile()
        layoutRetweet()
        
        if retweetHeight == 0 {
            layoutPics()
            if picHeight == 0 {
                layoutCard()
            }
        }
        
        layoutText()
        layoutTag()
        layoutToolbar()
        
        var height = CGFloat(0)
        height += marginTop
        height += titleHeight
        height += profileHeight
        height += textHeight
        if retweetHeight > 0 {
            height += retweetHeight
        } else if picHeight > 0 {
            height += retweetHeight
        } else if cardHeight > 0 {
            height += cardHeight
        }
        if tagHeight > 0 {
            height += tagHeight
        } else {
            if picHeight > 0 || cardHeight > 0 {
                height += WeiboStatusLayoutConfig.kWBCellPadding
            }
        }
        height += toolbarHeight
        height += marginBottom
    }
}

/// WeiboTextLinePositionModifier
class WeiboTextLinePositionModifier: NSObject, NSCopying {
    var font: UIFont = UIFont.systemFont(ofSize: 16)
    var paddingTop: CGFloat = 0
    var paddingBottom: CGFloat = 0
    var lineHeightMultiple: CGFloat = 1.34
    
    func height(for lineCount: Int) -> CGFloat {
        guard lineCount > 0 else { return 0 }
        return paddingTop + paddingBottom + font.pointSize * 0.86 + font.pointSize * 0.14 + (CGFloat(lineCount) - 1) * (font.pointSize * lineHeightMultiple)
    }
    
    required override init() {
        super.init()
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let cpy = type(of: self).init()
        cpy.font = font
        cpy.paddingBottom = paddingBottom
        cpy.paddingTop = paddingTop
        cpy.lineHeightMultiple = lineHeightMultiple
        return cpy
    }
}

extension WeiboTextLinePositionModifier: YYTextLinePositionModifier {
    
    func modifyLines(_ lines: [YYTextLine], fromText text: NSAttributedString, in container: YYTextContainer) {
        let pointSize = font.pointSize
        let ascent = pointSize * 0.86
        let lineHeight = pointSize * lineHeightMultiple
        lines.forEach { $0.position.y = paddingTop + ascent + CGFloat($0.row) * lineHeight }
    }
}

class WeiboTextImageViewAttachment: YYTextAttachment {
    var URL: URL?
    var size: CGSize = .zero
    fileprivate var imageView: UIImageView?
    override var content: Any? {
        get {
            if pthread_main_np() == 0 { return nil }
            if let imageView = self.imageView { return imageView }
            let imageView = UIImageView()
            imageView.size = size
            imageView.setImageWith(URL, placeholder: nil)
            self.imageView = imageView
            return imageView
        }
        set {
            guard let content = newValue as? UIImageView else { return }
            self.imageView = content
        }
    }
    
}
