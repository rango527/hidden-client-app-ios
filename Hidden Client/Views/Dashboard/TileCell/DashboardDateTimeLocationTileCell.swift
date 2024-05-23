//
//  DashboardDateTimeLocationTileCell.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class DashboardDateTimeLocationTileCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var label1Label: UILabel!
    @IBOutlet weak var label2Label: UILabel!
    @IBOutlet weak var label3Label: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var emptyMapPinImageView: UIImageView!
    @IBOutlet weak var mapTopLabel: UILabel!
    @IBOutlet weak var mapBottomLabel: UILabel!
    
    func setupCell(with tile: DashboardTile?) {
        layoutIfNeeded()
        
        photoImageView.setImage(with: tile?.photo)
        label1Label.text = tile?.label1
        label2Label.text = tile?.label2
        label3Label.text = tile?.label3
        
        mapTopLabel.text = tile?.mapOverlayValue?.top
        mapBottomLabel.text = tile?.mapOverlayValue?.bottom
        
        emptyMapPinImageView.isHidden = tile?.coordinate != nil
        mapImageView.image = nil
        
        HCMap.getSnapshot(coordinate: tile?.coordinate, radius: 1000, size: mapImageView.bounds.size) { [weak self] (image, coordinate) in
            if coordinate == tile?.coordinate {
                self?.mapImageView?.image = image
            }
        }
    }
}
