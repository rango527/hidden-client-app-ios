//
//  FeedbackCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/08.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol FeedbackCellDelegate: class {
    func rateQuestion(_ question: FeedbackQuestion, _ rate: Int)
    func approve(_ comment: String?)
}

class FeedbackCellView: UICollectionViewCell {
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var ratingView: UIStackView!
    
    var item: FeedbackQuestion!
    weak var delegate: FeedbackCellDelegate?
    
    func setupCell(with item: FeedbackQuestion) {
        self.item = item
        lblQuestion.text = item.question
        for view in ratingView.subviews {
            (view as? UIButton)?.isSelected = false
        }
    }
    
    @IBAction func onRate(_ sender: UIButton) {
        for tag in 1...sender.tag {
            (ratingView.viewWithTag(tag) as? UIButton)?.isSelected = true
        }
        delegate?.rateQuestion(self.item, sender.tag)
    }
}
