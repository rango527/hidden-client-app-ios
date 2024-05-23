//
//  HCTabBar.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class HCTabBar: UITabBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = super.sizeThatFits(size)
        size.height = size.height + Constants.TabBar.extraHeight
        return size
    }
}
