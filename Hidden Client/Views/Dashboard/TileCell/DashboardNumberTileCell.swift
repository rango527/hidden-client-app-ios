//
//  DashboardNumberTileCell.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class DashboardNumberTileCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func setupCell(with tile: DashboardTile?, colorScheme: DashboardItemColorScheme?) {
        titleLabel.text = tile?.title
        valueLabel.text = tile?.value
        
        if colorScheme == .light {
            titleLabel.superview?.backgroundColor = UIColor.white
            titleLabel.textColor = UIColor.hcDarkBlue
            valueLabel.textColor = UIColor.hcDarkBlue
        } else {
            titleLabel.superview?.backgroundColor = UIColor.hcDarkBlue
            titleLabel.textColor = UIColor.white
            valueLabel.textColor = UIColor.white
        }
    }
}
