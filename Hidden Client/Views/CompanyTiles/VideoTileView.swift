//
//  VideoTileView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class VideoTileView: CompanyTileView {

    @IBOutlet weak var itemImageView: UIImageView!
    
    override func setupTile(with item: CompanyTile) {
        super.setupTile(with: item)
        itemImageView.setImage(with: item.asset?.thumbnail, key: .companyTile(item.id))
    }
}
