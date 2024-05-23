//
//  WorkExperienceView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/03.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import BonMot

class WorkExperienceView: UIView {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var lblBrand: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    func setupView(_ item: WorkExperience) {
        logoImageView.setImage(with: item.asset, key: .experience(item.id))
        lblBrand.text = item.brand?.capitalized
        lblTitle.text = item.jobTitle?.capitalized
        lblDuration.text = item.durationText
        lblDescription.text = item.desc
    }
}
