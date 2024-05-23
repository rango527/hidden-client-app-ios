//
//  SettingsMenuCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/07.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class SettingsMenuCellView: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    
    func setupCell(with item: SettingsMenu) {
        self.selectionStyle = .none

        lblTitle.text = item.title
        if item.imageUrl != nil {
            itemImageView.setImage(with: item.imageUrl, key: item.imageKey)
        } else {
            itemImageView.image = nil
        }
        hero.modifiers = [.fade]
    }

}
