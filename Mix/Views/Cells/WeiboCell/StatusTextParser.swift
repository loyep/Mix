//
//  StatusTextParser.swift
//  Mix
//
//  Created by Maxwell on 12/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import YYText

class StatusTextParser: NSObject {
    
    static let linkRegex: NSRegularExpression = try! NSRegularExpression(pattern: "([https]+://[^\\s]*)", options: [])
    
}

extension StatusTextParser: YYTextParser {
    
    func parseText(_ text: NSMutableAttributedString?, selectedRange: NSRangePointer?) -> Bool {
        guard let text = text else { return false }
        var changed = false
        StatusTextParser.linkRegex.enumerateMatches(in: text.string, options: .withoutAnchoringBounds, range: text.yy_rangeOfAll()) { (reuslt, flag, stop) in
            guard let result = reuslt else { return }
            print("\(result.range)")
        }
        return changed
    }
    
}

extension StatusTextParser: YYTextLinePositionModifier {

    func modifyLines(_ lines: [YYTextLine], fromText text: NSAttributedString, in container: YYTextContainer) {
        
    }
}


extension StatusTextParser: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        return StatusTextParser()
    }
    
}
