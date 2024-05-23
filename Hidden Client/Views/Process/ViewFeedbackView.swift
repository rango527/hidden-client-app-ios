//
//  ViewFeedbackView.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/25.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ViewFeedbackView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    func setupView(with feedback: Feedback, candidateName: String) {
        let subtitle = getSubtitle(from: feedback)
        
        titleLabel.text = feedback.from == .client ? "Your Feedback" : "\(candidateName)'s Feedback"
        titleLabel.textColor = subtitle.color
        
        subtitleLabel.text = subtitle.text
        subtitleLabel.textColor = subtitle.color
        
        let comment = (feedback.from == .client ? feedback.comment : feedback.translated) ?? ""
        commentLabel.text = comment.isEmpty ? "No comments" : "\"\(comment)\""
        
        feedback.questions?.forEach({ (item) in
            let itemView = ViewFeedbackQuestionView.fromNib() as! ViewFeedbackQuestionView
            itemView.setupView(with: item)
            stackView.addArrangedSubview(itemView)
        })
    }
    
    private func getSubtitle(from feedback: Feedback) -> (text: String?, color: UIColor?) {
        var text: String?
        var color: UIColor?
        
        if feedback.type == .interview {
            if feedback.from == .candidate {
                if feedback.vote == .accepted {
                    text = "Progress to next stage"
                    color = UIColor.hcGreen
                } else {
                    text = "Pulled out of process"
                    color = UIColor.hcRed
                }
            } else {
                if feedback.vote == .accepted {
                    text = "Progress to next stage"
                    color = UIColor.hcGreen
                } else {
                    text = "Rejected candidate"
                    color = UIColor.hcRed
                }
            }
        } else {
            text = "Progress to next stage"
            color = UIColor.hcGreen
        }
        
        return (text, color)
    }
}
