//
//  HCTextField.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

extension UITextField {

    @IBInspectable var paddingLeftCustom: CGFloat {
        get {
            return leftView!.frame.size.width
        }
        set {
            setLeftPaddingPoints(newValue)
        }
    }

    @IBInspectable var paddingRightCustom: CGFloat {
        get {
            return rightView!.frame.size.width
        }
        set {
            setRightPaddingPoints(newValue)
        }
    }

    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    @IBInspectable var placeholderColor: UIColor? {
        get {
            return self.textColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [.foregroundColor: newValue ?? UIColor.lightGray])
        }
    }
}
