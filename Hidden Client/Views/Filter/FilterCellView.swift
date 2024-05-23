//
//  FilterCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 5/7/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class FilterCellView: UITableViewCell {

    @IBOutlet weak var filterTitleLabel: UILabel!
    @IBOutlet weak var filterContentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setCellTitle(with title: String) {
        filterTitleLabel.text = title
    }

    func setupJobCellContent(with jobFilters: [ProcessFilter]) {
        var contentString = String()
        jobFilters.forEach({ jobFilter in
            if jobFilter.isJobEmpty() == false {
                let content = "\(jobFilter.job ?? ""), \(jobFilter.location ?? "")"
                if contentString.isEmpty {
                    contentString = content
                } else { contentString = contentString + ", " + content }
            }
        })

        if contentString.isEmpty {
            filterContentLabel.text = "All"
        } else {
            filterContentLabel.text = contentString
        }
    }

    func setupExtraCellContent(with extraFilters: [ProcessFilter], type: String) {
        var contentString = String()
        extraFilters.forEach({ filter in
            if type == Constants.ProcessFilter.ProcessType.processStage, filter.isStageEmpty() == false {
                if contentString.isEmpty {
                    contentString = filter.stage ?? ""
                } else { contentString = contentString + ", " + filter.stage! }
            } else if type == Constants.ProcessFilter.ProcessType.readStatus, filter.isReadStatusEmpty() == false {
                if contentString.isEmpty {
                    contentString = filter.readStatus ?? ""
                } else { contentString = contentString + ", " + filter.readStatus! }
            }
        })

        if contentString.isEmpty {
            filterContentLabel.text = "All"
        } else {
            filterContentLabel.text = contentString
        }
    }

    func setupSingleCellContent(with filter: ProcessFilter, type: String) {
        if type == Constants.ProcessFilter.ProcessType.sortBy, filter.isSortByEmpty() == false {
            filterContentLabel.text = filter.sortBy
        } else if type == Constants.ProcessFilter.ProcessType.readStatus, filter.isReadStatusEmpty() == false {
            filterContentLabel.text = filter.readStatus
        } else {
            filterContentLabel.text = "All"
        }
    }
    
}
