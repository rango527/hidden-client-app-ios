//
//  TagView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

@IBDesignable
class TagView: UIButton {

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var textColor: UIColor = UIColor.black {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var selectedTextColor: UIColor = UIColor.white {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var progressBarColor: UIColor = UIColor.colorFrom(rgb: 0x57CA85) {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var progressBarHeight: CGFloat = 4 {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable var ranking: CGFloat = 0.0 {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable var titleLineBreakMode: NSLineBreakMode = .byTruncatingMiddle {
        didSet {
            titleLabel?.lineBreakMode = titleLineBreakMode
        }
    }
    
    @IBInspectable var paddingY: CGFloat = 5 {
        didSet {
            titleEdgeInsets.top = paddingY
            titleEdgeInsets.bottom = paddingY
        }
    }
    
    @IBInspectable var paddingX: CGFloat = 5 {
        didSet {
            titleEdgeInsets.left = paddingX
            updateRightInsets()
        }
    }
    
    @IBInspectable var tagBackgroundColor: UIColor = UIColor.colorFrom(rgb: 0xE6E4E4) {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var highlightedBackgroundColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var selectedBorderColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var selectedBackgroundColor: UIColor? {
        didSet {
            reloadStyles()
        }
    }
    
    @IBInspectable var textFont: UIFont = UIFont.avenirOblique(12) {
        didSet {
            titleLabel?.font = textFont
        }
    }
    
    private func reloadStyles() {
        if isHighlighted {
            if let highlightedBackgroundColor = highlightedBackgroundColor {
                // For highlighted, if it's nil, we should not fallback to backgroundColor.
                // Instead, we keep the current color.
                backgroundColor = highlightedBackgroundColor
            }
        }
        else if isSelected {
            backgroundColor = selectedBackgroundColor ?? tagBackgroundColor
            layer.borderColor = selectedBorderColor?.cgColor ?? borderColor?.cgColor
            setTitleColor(selectedTextColor, for: UIControl.State())
        }
        else {
            backgroundColor = tagBackgroundColor
            layer.borderColor = borderColor?.cgColor
            setTitleColor(textColor, for: UIControl.State())
        }
        progressView.backgroundColor = progressBarColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            reloadStyles()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            reloadStyles()
        }
    }
    
    // MARK: progress
    let progressView = UIView()
    
    
    // MARK: remove button
    
    let removeButton = CloseButton()
    
    @IBInspectable var enableRemoveButton: Bool = false {
        didSet {
            removeButton.isHidden = !enableRemoveButton
            updateRightInsets()
        }
    }
    
    @IBInspectable var removeButtonIconSize: CGFloat = 12 {
        didSet {
            removeButton.iconSize = removeButtonIconSize
            updateRightInsets()
        }
    }
    
    @IBInspectable var removeIconLineWidth: CGFloat = 3 {
        didSet {
            removeButton.lineWidth = removeIconLineWidth
        }
    }
    @IBInspectable var removeIconLineColor: UIColor = UIColor.white.withAlphaComponent(0.54) {
        didSet {
            removeButton.lineColor = removeIconLineColor
        }
    }
    
    /// Handles Tap (TouchUpInside)
    var onTap: ((TagView) -> Void)?
    var onLongPress: ((TagView) -> Void)?
    
    // MARK: - init
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    public init(title: String) {
        super.init(frame: CGRect.zero)
        setTitle(title, for: UIControl.State())
        
        setupView()
    }
    
    public init(attributedTitle: NSAttributedString) {
        super.init(frame: CGRect.zero)
        setAttributedTitle(attributedTitle, for: UIControl.State())
        
        setupView()
    }
    
    private func setupView() {
        titleLabel?.lineBreakMode = titleLineBreakMode
        
        frame.size = intrinsicContentSize
        addSubview(removeButton)
        addSubview(progressView)
        removeButton.tagView = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress))
        self.addGestureRecognizer(longPress)
    }
    
    @objc func longPress() {
        onLongPress?(self)
    }
    
    // MARK: - layout
    override var intrinsicContentSize: CGSize {
        var size = titleLabel?.text?.size(withAttributes: [NSAttributedString.Key.font: textFont]) ?? CGSize.zero
        size.height = textFont.pointSize + paddingY * 2
        size.width += paddingX * 2
        if size.width < size.height {
            size.width = size.height
        }
        if image(for: UIControl.State()) != nil {
            size.width += 30
        }
        if enableRemoveButton {
            size.width += removeButtonIconSize + paddingX
        }
        return size
    }
    
    private func updateRightInsets() {
        if enableRemoveButton {
            titleEdgeInsets.right = paddingX  + removeButtonIconSize + paddingX
        }
        else {
            titleEdgeInsets.right = paddingX
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if enableRemoveButton {
            removeButton.frame.size.width = paddingX + removeButtonIconSize + paddingX
            removeButton.frame.origin.x = self.frame.width - removeButton.frame.width
            removeButton.frame.size.height = self.frame.height
            removeButton.frame.origin.y = 0
        }
        
        progressView.frame.size.width = ranking / 5.0 * self.frame.width
        progressView.frame.size.height = progressBarHeight
        progressView.frame.origin.x = 0
        progressView.frame.origin.y = self.frame.height - progressBarHeight
        
        cornerRadius = self.frame.height / 2.0
    }
}

#if !(swift(>=4.2))
private extension NSAttributedString {
    typealias Key = NSAttributedStringKey
}
private extension UIControl {
    typealias State = UIControlState
}
#endif
