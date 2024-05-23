//
//  FilterDetailCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 5/14/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class FilterDetailCellView: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkedImageView: UIImageView!

    var cellSelected: Bool! = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setupCell(with title: String) {
        titleLabel.text = title
    }

    func setupJobCell(with item: ShortListFilter, active: Bool) {
        if item.isEmpty() {
            titleLabel.text = "All"
        } else {
            titleLabel.text = "\(item.job ?? ""), \(item.location ?? "")"
        }

        cellSelected = active
        setSelectedStatus()
        //titleLabel.textColor = active ? UIColor.colorFrom(rgb: 0xe74a5f) : UIColor.colorFrom(rgb: 0x8c8c8c)
    }

    func setupStageCell(with item: ProcessFilter, active: Bool) {
        if item.isStageEmpty() {
            titleLabel.text = "All"
        } else {
            titleLabel.text = item.stage
        }

        cellSelected = active
        setSelectedStatus()

        //titleLabel.textColor = active ? UIColor.colorFrom(rgb: 0xe74a5f) : UIColor.colorFrom(rgb: 0x8c8c8c)
    }

    func setupReadStatusCell(with item: ProcessFilter, active: Bool) {
        if item.isReadStatusEmpty() {
            titleLabel.text = "All"
        } else {
            titleLabel.text = item.readStatus
        }

        cellSelected = active
        setSelectedStatus()

        //titleLabel.textColor = active ? UIColor.colorFrom(rgb: 0xe74a5f) : UIColor.colorFrom(rgb: 0x8c8c8c)
    }

    func setupSortByCell(with item: ProcessFilter, active: Bool) {        
        if item.isSortByEmpty() {
            titleLabel.text = "All"
        } else {
            titleLabel.text = item.sortBy
        }

        cellSelected = active
        setSelectedStatus()
        //titleLabel.textColor = active ? UIColor.colorFrom(rgb: 0xe74a5f) : UIColor.colorFrom(rgb: 0x8c8c8c)
    }

    func setSelectedStatus() {
        //check mark
        if cellSelected {
            checkedImageView.image = UIImage(named: "checked-icon")
        } else {
            checkedImageView.image = UIImage(named: "unchecked-icon")
        }

        titleLabel.layoutIfNeeded()
        contentView.layoutIfNeeded()
        layoutIfNeeded()
    }
}
