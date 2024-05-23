//
//  HCSegmentedControl.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/13/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    
    func font(name:String?, size:CGFloat?) {
        let attributedSegmentFont = NSDictionary(object: UIFont(name: name!, size: size!)!, forKey: NSAttributedString.Key.font as NSCopying)
        setTitleTextAttributes(attributedSegmentFont as? [NSAttributedString.Key : Any], for: .normal)
    }
}
