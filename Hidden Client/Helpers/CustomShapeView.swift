//
//  CustomShapeView.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/13.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

@IBDesignable class CustomShapeView: UIView {

    @IBInspectable var type: String = "Right Triangle" {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var color: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        switch type {
        case "Right Triangle":
            context.beginPath()
            context.move(to: CGPoint(x: 0, y: 0))
            context.addLine(to: CGPoint(x: 0.0, y: frame.size.height))
            context.addLine(to: CGPoint(x: frame.size.width, y: frame.size.height))
            context.closePath()
            
            context.setFillColor(color.cgColor)
            context.fillPath()
        default:
            return
        }
    }
}
