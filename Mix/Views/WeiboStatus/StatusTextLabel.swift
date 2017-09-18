//
//  WeiboLabel.swift
//  Mix
//
//  Created by Maxwell on 13/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import YYKit

class StatusTextLabel: YYLabel {
    
    override var text: String? {
        willSet {
            guard newValue != text else {
                return
            }
            
            if let text = newValue {
                self.textLayout = yyTextLayout(text)
            } else {
                self.textLayout = nil
            }
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            if let textLayout = textLayout {
                let textAttr = NSMutableAttributedString(attributedString: textLayout.text)
                textAttr.setColor(tintColor, range: textAttr.rangeOfAll())
                let container = YYTextContainer()
                container.size = CGSize(width: frame.width, height: CGFloat(MAXFLOAT))
                container.insets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
                let layout = YYTextLayout(container: container, text: textAttr)!
                self.textLayout = layout
            }
        }
    }
    
    override var textLayout: YYTextLayout? {
        willSet {
            if let textLayout = newValue {
                self.frame.size.height = textLayout.textBoundingSize.height
            } else {
                self.frame.size.height = 0
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        ignoreCommonProperties = true
        displaysAsynchronously = true
        fadeOnAsynchronouslyDisplay = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func yyTextLayout(_ text: String) -> YYTextLayout {
        let textAttr = text.weibStatusAttributedString(tintColor)
        let container = YYTextContainer(size: CGSize(width: frame.width, height: CGFloat(MAXFLOAT)), insets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        let lineModifier = WeiboTextLinePositionModifier()
        lineModifier.paddingTop = WeiboStatusLayoutConfig.kWBCellPaddingText
        lineModifier.paddingBottom = WeiboStatusLayoutConfig.kWBCellPaddingText
        container.linePositionModifier = lineModifier
        return YYTextLayout(container: container, text: textAttr)!
    }
    
}

extension StatusTextLabel {
    
    func text(from text: String, fontSize: CGFloat, color: UIColor) -> NSMutableAttributedString {
        
//        if (!status) return nil;
//
//        NSMutableString *string = status.text.mutableCopy;
//        if (string.length == 0) return nil;
//        if (isRetweet) {
//            NSString *name = status.user.name;
//            if (name.length == 0) {
//                name = status.user.screenName;
//            }
//            if (name) {
//                NSString *insert = [NSString stringWithFormat:@"@%@:",name];
//                [string insertString:insert atIndex:0];
//            }
//        }
//        // 字体
//        UIFont *font = [UIFont systemFontOfSize:fontSize];
//        // 高亮状态的背景
//        YYTextBorder *highlightBorder = [YYTextBorder new];
//        highlightBorder.insets = UIEdgeInsetsMake(-2, 0, -2, 0);
//        highlightBorder.cornerRadius = 3;
//        highlightBorder.fillColor = kWBCellTextHighlightBackgroundColor;
//
        let text = NSMutableAttributedString(string: text)
        text.font = UIFont.systemFont(ofSize: fontSize)
        text.color = color
//        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:string];
//        text.font = font;
//        text.color = textColor;
//
//        // 根据 urlStruct 中每个 URL.shortURL 来匹配文本，将其替换为图标+友好描述
//        for (WBURL *wburl in status.urlStruct) {
//            if (wburl.shortURL.length == 0) continue;
//            if (wburl.urlTitle.length == 0) continue;
//            NSString *urlTitle = wburl.urlTitle;
//            if (urlTitle.length > 27) {
//                urlTitle = [[urlTitle substringToIndex:27] stringByAppendingString:YYTextTruncationToken];
//            }
//            NSRange searchRange = NSMakeRange(0, text.string.length);
//            do {
//                NSRange range = [text.string rangeOfString:wburl.shortURL options:kNilOptions range:searchRange];
//                if (range.location == NSNotFound) break;
//
//                if (range.location + range.length == text.length) {
//                    if (status.pageInfo.pageID && wburl.pageID &&
//                        [wburl.pageID isEqualToString:status.pageInfo.pageID]) {
//                        if ((!isRetweet && !status.retweetedStatus) || isRetweet) {
//                            if (status.pics.count == 0) {
//                                [text replaceCharactersInRange:range withString:@""];
//                                break; // cut the tail, show with card
//                            }
//                        }
//                    }
//                }
//
//                if ([text attribute:YYTextHighlightAttributeName atIndex:range.location] == nil) {
//
//                    // 替换的内容
//                    NSMutableAttributedString *replace = [[NSMutableAttributedString alloc] initWithString:urlTitle];
//                    if (wburl.urlTypePic.length) {
//                        // 链接头部有个图片附件 (要从网络获取)
//                        NSURL *picURL = [WBStatusHelper defaultURLForImageURL:wburl.urlTypePic];
//                        UIImage *image = [[YYImageCache sharedCache] getImageForKey:picURL.absoluteString];
//                        NSAttributedString *pic = (image && !wburl.pics.count) ? [self _attachmentWithFontSize:fontSize image:image shrink:YES] : [self _attachmentWithFontSize:fontSize imageURL:wburl.urlTypePic shrink:YES];
//                        [replace insertAttributedString:pic atIndex:0];
//                    }
//                    replace.font = font;
//                    replace.color = kWBCellTextHighlightColor;
//
//                    // 高亮状态
//                    YYTextHighlight *highlight = [YYTextHighlight new];
//                    [highlight setBackgroundBorder:highlightBorder];
//                    // 数据信息，用于稍后用户点击
//                    highlight.userInfo = @{kWBLinkURLName : wburl};
//                    [replace setTextHighlight:highlight range:NSMakeRange(0, replace.length)];
//
//                    // 添加被替换的原始字符串，用于复制
//                    YYTextBackedString *backed = [YYTextBackedString stringWithString:[text.string substringWithRange:range]];
//                    [replace setTextBackedString:backed range:NSMakeRange(0, replace.length)];
//
//                    // 替换
//                    [text replaceCharactersInRange:range withAttributedString:replace];
//
//                    searchRange.location = searchRange.location + (replace.length ? replace.length : 1);
//                    if (searchRange.location + 1 >= text.length) break;
//                    searchRange.length = text.length - searchRange.location;
//                } else {
//                    searchRange.location = searchRange.location + (searchRange.length ? searchRange.length : 1);
//                    if (searchRange.location + 1>= text.length) break;
//                    searchRange.length = text.length - searchRange.location;
//                }
//            } while (1);
//        }
//
//        // 根据 topicStruct 中每个 Topic.topicTitle 来匹配文本，标记为话题
//        for (WBTopic *topic in status.topicStruct) {
//            if (topic.topicTitle.length == 0) continue;
//            NSString *topicTitle = [NSString stringWithFormat:@"#%@#",topic.topicTitle];
//            NSRange searchRange = NSMakeRange(0, text.string.length);
//            do {
//                NSRange range = [text.string rangeOfString:topicTitle options:kNilOptions range:searchRange];
//                if (range.location == NSNotFound) break;
//
//                if ([text attribute:YYTextHighlightAttributeName atIndex:range.location] == nil) {
//                    [text setColor:kWBCellTextHighlightColor range:range];
//
//                    // 高亮状态
//                    YYTextHighlight *highlight = [YYTextHighlight new];
//                    [highlight setBackgroundBorder:highlightBorder];
//                    // 数据信息，用于稍后用户点击
//                    highlight.userInfo = @{kWBLinkTopicName : topic};
//                    [text setTextHighlight:highlight range:range];
//                }
//                searchRange.location = searchRange.location + (searchRange.length ? searchRange.length : 1);
//                if (searchRange.location + 1>= text.length) break;
//                searchRange.length = text.length - searchRange.location;
//            } while (1);
//        }
//
//        // 匹配 @用户名
//        NSArray *atResults = [[WBStatusHelper regexAt] matchesInString:text.string options:kNilOptions range:text.rangeOfAll];
//        for (NSTextCheckingResult *at in atResults) {
//            if (at.range.location == NSNotFound && at.range.length <= 1) continue;
//            if ([text attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
//                [text setColor:kWBCellTextHighlightColor range:at.range];
//
//                // 高亮状态
//                YYTextHighlight *highlight = [YYTextHighlight new];
//                [highlight setBackgroundBorder:highlightBorder];
//                // 数据信息，用于稍后用户点击
//                highlight.userInfo = @{kWBLinkAtName : [text.string substringWithRange:NSMakeRange(at.range.location + 1, at.range.length - 1)]};
//                [text setTextHighlight:highlight range:at.range];
//            }
//        }
//
//        // 匹配 [表情]
//        NSArray<NSTextCheckingResult *> *emoticonResults = [[WBStatusHelper regexEmoticon] matchesInString:text.string options:kNilOptions range:text.rangeOfAll];
//        NSUInteger emoClipLength = 0;
//        for (NSTextCheckingResult *emo in emoticonResults) {
//            if (emo.range.location == NSNotFound && emo.range.length <= 1) continue;
//            NSRange range = emo.range;
//            range.location -= emoClipLength;
//            if ([text attribute:YYTextHighlightAttributeName atIndex:range.location]) continue;
//            if ([text attribute:YYTextAttachmentAttributeName atIndex:range.location]) continue;
//            NSString *emoString = [text.string substringWithRange:range];
//            NSString *imagePath = [WBStatusHelper emoticonDic][emoString];
//            UIImage *image = [WBStatusHelper imageWithPath:imagePath];
//            if (!image) continue;
//
//            NSAttributedString *emoText = [NSAttributedString attachmentStringWithEmojiImage:image fontSize:fontSize];
//            [text replaceCharactersInRange:range withAttributedString:emoText];
//            emoClipLength += range.length - 1;
//        }
        
        return text;
    }
}
