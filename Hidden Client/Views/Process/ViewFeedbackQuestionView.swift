//
//  ViewFeedbackQuestionView.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/25.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ViewFeedbackQuestionView: UIView {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var rateStackView: UIStackView!
    
    func setupView(with question: FeedbackQuestion) {        
        questionLabel.text = question.question
        let score = Int(question.score ?? "") ?? 0
        for i in 1...5 {
            (rateStackView.viewWithTag(i) as? UIButton)?.isSelected = i <= score
        }
    }
}
