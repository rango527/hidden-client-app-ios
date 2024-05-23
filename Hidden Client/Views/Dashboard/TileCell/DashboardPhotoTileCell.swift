//
//  DashboardPhotoTileCell.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class DashboardPhotoTileCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    func setupCell(with tile: DashboardTile?) {
        photoImageView.setImage(with: tile?.photo)
        tagView.backgroundColor = tile?.tagColorValue
        tagLabel.text = tile?.tag
        titleLabel.text = tile?.title
        subtitleLabel.text = tile?.subtitle
    }
}
