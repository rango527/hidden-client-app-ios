//
//  HCView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

enum LINE_POSITION {
    case LINE_POSITION_TOP
    case LINE_POSITION_BOTTOM
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    static func fromNib() -> UIView? {
        let name = String(describing: self)
        return Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? UIView
    }
    
    @discardableResult func addGradientLayer(_ colors: [UIColor], start: CGPoint? = nil, end: CGPoint? = nil) -> CAGradientLayer {
        if let gradientLayer = gradientLayer { return gradientLayer }
        
        let gradient = CAGradientLayer()
        
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = start ?? CGPoint(x: 0.5, y: 0)
        gradient.endPoint = end ?? CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradient, at: 0)
        
        return gradient
    }
    
    func removeGradientLayer() -> CAGradientLayer? {
        gradientLayer?.removeFromSuperlayer()
        
        return gradientLayer
    }
    
    func resizeGradientLayer() {
        gradientLayer?.frame = bounds
    }
    
    fileprivate var gradientLayer: CAGradientLayer? {
        return layer.sublayers?.first as? CAGradientLayer
    }
    
    func addRoundView() {
        let width = UIScreen.main.bounds.width
        let height = bounds.height
        let w = (width * width / 4.0 + height * height) / height
        let roundView = UIView(frame: CGRect(x: (width - w)/2.0, y: 0, width: w, height: 2 * height))
        roundView.cornerRadius = w / 2.0
        roundView.backgroundColor = UIColor.white
        addSubview(roundView)
    }

    func addLine(position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        self.addSubview(lineView)

        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))

        switch position {
        case .LINE_POSITION_TOP:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        }
    }
}
