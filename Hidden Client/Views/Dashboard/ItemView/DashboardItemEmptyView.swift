//
//  DashboardItemEmptyView.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class DashboardItemEmptyView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func setupView(with item: DashboardItem) {
        if let iconName = item.emptyStateIcon, let image = UIImage(named: iconName) {
            imageView.image = image
        } else if let iconUrl = item.emptyStateIconUrl {
            imageView.setImage(with: iconUrl)
        }
        descriptionLabel.text = item.emptyStateDescription
    }
}
