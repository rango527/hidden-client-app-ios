//
//  MemberTileCell.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class MemberTileCell: UICollectionViewCell {

    @IBOutlet weak var memberImageView: UIImageView!
    @IBOutlet weak var lblContent: UILabel!
    
    func setupCell(with item: CompanyPerson) {
        memberImageView.setImage(with: item.asset)
        lblContent.attributedText = item.styledContent
    }

}
