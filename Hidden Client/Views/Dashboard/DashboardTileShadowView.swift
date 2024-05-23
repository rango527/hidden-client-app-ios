//
//  DashboardTileShadowView.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/13.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class DashboardTileShadowView: UIView {

    var shadowLayer: CAShapeLayer!
    let radius: CGFloat = 20
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: radius).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
            shadowLayer.shadowOpacity = 0.24
            shadowLayer.shadowRadius = 4
            
            layer.insertSublayer(shadowLayer, below: nil)
        }
    }
}
