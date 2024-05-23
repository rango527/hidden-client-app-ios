//
//  SettingCellHeaderView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/6/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class SettingCellHeaderView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var btnHelp: UIButton!

    func setupCell(with title: String, itemsCount: Int) {
        
        if itemsCount > 1 {
            lblTitle.text = title + "s"
        } else {
            lblTitle.text = title
        }
    }
}
