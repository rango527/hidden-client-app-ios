//
//  MoreFeedbackCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView

class MoreFeedbackCellView: UICollectionViewCell {

    @IBOutlet weak var commentTextView: RSKPlaceholderTextView!
    @IBOutlet weak var btnAction: UIButton!
    weak var delegate: FeedbackCellDelegate?

    func setupCell(with acceptance: Bool) {
        if acceptance == true {
            btnAction.backgroundColor = Constants.HiddenColor.green
            btnAction.setTitle("Submit", for: .normal)
        } else {
            btnAction.backgroundColor = Constants.HiddenColor.red
            btnAction.setTitle("Submit", for: .normal)
        }
    }
    
    @IBAction func onApproveFeedback(_ sender: UIButton) {
        delegate?.approve(commentTextView.text)
    }
}
