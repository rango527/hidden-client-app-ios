//
//  HCHUD.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/08/30.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation
import PKHUD

extension PKHUD {
    static func flashOnTop(with message: String, _ color: UIColor? = nil) {
        let messageHeight: CGFloat = 76
        var height: CGFloat = messageHeight
        let window = UIApplication.shared.keyWindow
        var messageTopInset: CGFloat = 0
        if let topInset = window?.safeAreaInsets.top {
            height += topInset
            messageTopInset += topInset
        }
        
      
        
        let view = UIView(frame: CGRect(x: 0, y: -height, width: UIScreen.main.bounds.width, height: height))
        view.backgroundColor = color ?? UIColor.hcGreen
        
        let label = UILabel(frame: CGRect(x: 0, y: messageTopInset, width: view.bounds.width, height: messageHeight))
        label.backgroundColor = .clear
        label.text = message
        label.font = UIFont.avenirHeavy(20)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.white
        
        view.addSubview(label)
        UIApplication.shared.keyWindow?.addSubview(view)
        
        UIView.animate(withDuration: 0.28, animations: {
            view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        }) { (_) in
            UIView.animate(withDuration: 0.28, delay: 2.4, options: .curveEaseIn, animations: {
                view.frame = CGRect(x: 0, y: -height, width: UIScreen.main.bounds.width, height: height)
            }, completion: { (_) in
                view.removeFromSuperview()
            })
        }
    }
}
