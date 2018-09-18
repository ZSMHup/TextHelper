//
//  AYTextHelper.swift
//  AYTextHelper
//
//  Created by 张书孟 on 2018/5/15.
//  Copyright © 2018年 ZSM. All rights reserved.
//

import UIKit

class AYTextHelper: NSObject {
    
    private lazy var textStorage: NSTextStorage = { NSTextStorage() }()
    
    private lazy var layoutManager: NSLayoutManager = { NSLayoutManager() }()
    
    private lazy var textContainer: NSTextContainer = { NSTextContainer() }()
    
    override init() {
        super.init()
        
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
    }
    
    func select(location: CGPoint, label: UILabel, selectedBlock: @escaping (Int, NSAttributedString) -> ()) {
        var location = location
        
        textContainer.size = label.bounds.size
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        let attributedText: NSMutableAttributedString = NSMutableAttributedString(attributedString: label.attributedText ?? NSAttributedString())
        let textRange: NSRange = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(NSAttributedStringKey.font, value: label.font, range: textRange)
        
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = label.textAlignment
        attributedText.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: textRange)
        
        textStorage.setAttributedString(attributedText)
        
        let textSize: CGSize = layoutManager.usedRect(for: textContainer).size
        location.y -= (label.frame.size.height - textSize.height)/2
        
        let glyphIndex: Int = layoutManager.glyphIndex(for: location, in: textContainer)
        
        let fontPointSize: CGFloat = label.font.pointSize
        layoutManager.setAttachmentSize(CGSize(width: fontPointSize, height: fontPointSize), forGlyphRange: NSRange(location: (label.text?.count ?? 1) - 1, length: 1))
        
        guard let attributedSubstring = label.attributedText?.attributedSubstring(from: NSRange(location: glyphIndex, length: 1)) else {
            return selectedBlock(-1, NSAttributedString())
        }
        
        let glyphRect: CGRect = (layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer))
        
        guard glyphRect.contains(location) else {
            return selectedBlock(-1, NSAttributedString())
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
        isUserInteractionEnabled = true
        ay_textHelper = AYTextHelper()
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func tapAction(tap: UITapGestureRecognizer) {
        let location: CGPoint = tap.location(in: tap.view)
        if let lable = tap.view as? UILabel {
            ay_textHelper.select(location: location, label: lable, selectedBlock: { [weak self] (index, charAttributedString) in
                guard let `self` = self else { return }
                self.ay_tapBlock(index, charAttributedString)
            })
        }
    }
}
