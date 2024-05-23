//
//  ImageTileView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ImageTileView: CompanyTileView {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    override func setupTile(with item: CompanyTile) {
        super.setupTile(with: item)
        itemImageView.setImage(with: item.asset, key: .companyTile(item.id)) { [weak self] (image) in
            DispatchQueue.main.async {
                if let img = image, img.size.width > 0 {
                    self?.heightConstraint.constant = UIScreen.main.bounds.width * img.size.height / img.size.width
                    self?.layoutIfNeeded()
                }
            }
        }

    }
}
