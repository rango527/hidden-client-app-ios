//
//  TimelineFeedbackQuestionView.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/31/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class TimelineFeedbackQuestionView: UIView {

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var rateStackView: UIStackView!

    func setupView(with question: FeedbackQuestion) {
        questionLabel.text = question.question
        let score = Int(question.score ?? "") ?? 0
        for i in 1...5 {
            (rateStackView.viewWithTag(i) as? UIButton)?.isSelected = i <= score
        }
    }

    func heightOfView(question: FeedbackQuestion) -> CGFloat {
        return 48 + (question.question?.heightWithConstrainedWidth(width: questionLabel.frame.size.width - 40,
                                                                    font: questionLabel.font) ?? 0.0)
    }
}
