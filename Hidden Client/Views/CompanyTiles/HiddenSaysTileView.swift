//
//  HiddenSaysTileView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/14.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class HiddenSaysTileView: UIView {

    @IBOutlet weak var lblHiddenSays: UILabel!
    
    func setupTile(with item: String?) {
        lblHiddenSays.text = item
    }
}
