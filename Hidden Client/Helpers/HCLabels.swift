//
//  HCAlignedInsetLabel.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/27/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

@IBDesignable class HCAlignedInsetLabel: UILabel {
    enum VerticalAlignment {
        case top
        case bottom
        case middle
    }

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0

    public var verticalAlignment: VerticalAlignment = .middle {
        didSet {
            self.sizeToFit()
            self.setNeedsDisplay()
            self.layoutIfNeeded()
        }
    }

    init(frame: CGRect, verticalAlignment: VerticalAlignment = .middle) {
        super.init(frame: frame)
        self.verticalAlignment = verticalAlignment
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.verticalAlignment = .middle
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect:CGRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)

        switch self.verticalAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        case .middle:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0
        }

        return textRect
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        let actualRect = self.textRect(forBounds: rect, limitedToNumberOfLines: 1)
        let sideMargin = leftInset + rightInset
        let increasedRect = CGRect(x: actualRect.origin.x - leftInset, y: actualRect.origin.y, width: actualRect.size.width + sideMargin, height: actualRect.size.height)
        super.drawText(in: increasedRect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

extension UILabel {

    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // (Swift 4.2 and above) Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        self.attributedText = attributedString
    }

}
