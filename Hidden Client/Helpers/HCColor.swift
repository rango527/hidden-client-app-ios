//
//  HCColor.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

extension UIColor {

    static func colorFrom(rgb: Int, alpha: CGFloat = 1) -> UIColor {
        return UIColor(
            red: CGFloat((rgb & 0xff0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00ff00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000ff) / 255.0,
            alpha: alpha
        )
    }

    static var hcMain: UIColor { return UIColor.colorFrom(rgb: 0x000040) }
    static var hcGreen: UIColor { return UIColor.colorFrom(rgb: 0x41d07e) } // 54ce76
    static var hcGreenSecond: UIColor { return UIColor.colorFrom(rgb: 0x5fcd6d) }
    static var hcRed: UIColor { return UIColor.colorFrom(rgb: 0xeb4a5f) }   // ed3d61
    static var hcDarkBlue: UIColor { return UIColor.colorFrom(rgb: 0x00053b) }
    static var hcLightGray: UIColor { return UIColor.colorFrom(rgb: 0xc8c8c8) }

}
