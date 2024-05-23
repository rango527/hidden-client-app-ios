//
//  ShortListFilterCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ShortListFilterCellView: UITableViewCell {
    
    @IBOutlet weak var lblFilter: UILabel!
    
    func setupCell(with item: ShortListFilter, active: Bool) {
        
        if item.isEmpty() {
            lblFilter.text = "All"
        } else {
            lblFilter.text = "\(item.job ?? ""), \(item.location ?? "")"
        }
        
        lblFilter.textColor = active ? UIColor.colorFrom(rgb: 0xe74a5f) : UIColor.colorFrom(rgb: 0x8c8c8c)
    }
}
