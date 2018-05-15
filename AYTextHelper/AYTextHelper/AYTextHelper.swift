//
//  AYTextHelper.swift
//  AYTextHelper
//
//  Created by 张书孟 on 2018/5/15.
//  Copyright © 2018年 ZSM. All rights reserved.
//

import UIKit

class AYTextHelper: NSObject {
    
    var textStorage: NSTextStorage?
    var layoutManager: NSLayoutManager?
    var textContainer: NSTextContainer?
    
    override init() {
        super.init()
        textStorage = NSTextStorage()
        layoutManager = NSLayoutManager()
        textContainer = NSTextContainer()
        textStorage?.addLayoutManager(layoutManager!)
        layoutManager?.addTextContainer(textContainer!)
    }
    
    func select(location: CGPoint, label: UILabel, selectedBlock: @escaping (Int, NSAttributedString) -> ()) {
        var location = location
        textContainer?.size = label.bounds.size
        textContainer?.lineFragmentPadding = 0
        textContainer?.maximumNumberOfLines = label.numberOfLines
        textContainer?.lineBreakMode = label.lineBreakMode
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(attributedString: label.attributedText!)
        let textRange: NSRange = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(NSAttributedStringKey.font, value: label.font, range: textRange)
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = label.textAlignment
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: textRange)
        
        textStorage?.setAttributedString(attributedText)
        
        let textSize: CGSize = layoutManager?.usedRect(for: textContainer ?? NSTextContainer()).size ?? CGSize.zero
        location.y -= (label.frame.size.height - textSize.height)/2
        
        let glyphIndex: Int = layoutManager?.glyphIndex(for: location, in: textContainer ?? NSTextContainer()) ?? 0
        
        let fontPointSize: CGFloat = label.font.pointSize
        layoutManager?.setAttachmentSize(CGSize.init(width: fontPointSize, height: fontPointSize), forGlyphRange: NSRange.init(location: (label.text?.count ?? 1) - 1, length: 1))
        
        let attributedSubstring: NSMutableAttributedString = label.attributedText?.attributedSubstring(from: NSRange.init(location: glyphIndex, length: 1)) as! NSMutableAttributedString
        
        let glyphRect: CGRect = (layoutManager?.boundingRect(forGlyphRange: NSRange.init(location: glyphIndex, length: 1), in: textContainer ?? NSTextContainer()))!
        
        if !glyphRect.contains(location) {
            selectedBlock(-1, NSAttributedString())
        }
        selectedBlock(glyphIndex, attributedSubstring)
    }
}


var TapBlock = "TapBlock"
var TextHelper = "TextHelper"

extension UILabel {
    
    private var ay_textHelper: AYTextHelper {
        get {
            return objc_getAssociatedObject(self, &TextHelper) as! AYTextHelper
        }
        set {
            objc_setAssociatedObject(self, &TextHelper, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    private var ay_tapBlock: ((Int, NSAttributedString) -> Void) {
        get {
            return objc_getAssociatedObject(self, &TapBlock) as! ((Int, NSAttributedString) -> Void)
        }
    }
    
    public func setTap(block: @escaping (Int, NSAttributedString) -> ()) {
        objc_setAssociatedObject(self, &TapBlock, block, .OBJC_ASSOCIATION_COPY)
        self.isUserInteractionEnabled = true
        ay_textHelper = AYTextHelper()
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapAction(tap: UITapGestureRecognizer) {
        let location: CGPoint = tap.location(in: tap.view)
        
        ay_textHelper.select(location: location, label: tap.view as! UILabel, selectedBlock: {[weak self] (index, charAttributedString) in
            if self?.ay_tapBlock != nil {
                self?.ay_tapBlock(index, charAttributedString)
            }
        })
    }
}
