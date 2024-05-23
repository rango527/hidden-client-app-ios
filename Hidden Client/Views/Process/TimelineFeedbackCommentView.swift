//
//  TimelineFeedbackCommentView.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/30/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class TimelineFeedbackCommentView: UIView {

    @IBOutlet weak var commentLabel: UILabel!

    func setupView(with feedback: Feedback) {
        self.cornerRadius = 10
        let comment = feedback.comment ?? ""
        commentLabel.text = comment.isEmpty ? "No comments" : "\"\(comment)\""
    }

    func setupView(with interviewerFeedback: InterviewParticipant) {
        self.cornerRadius = 10
        let comment = interviewerFeedback.comment ?? ""
        commentLabel.text = comment.isEmpty ? "No comments" : "\"\(comment)\""
    }

    func heightOfView(feedback: Feedback) -> CGFloat {
        return 64 + (feedback.comment?.heightWithConstrainedWidth(width: commentLabel.frame.size.width, font: commentLabel.font) ?? 0.0)
    }

    func heightOfView(interviewerFeedback: InterviewParticipant) -> CGFloat {
        return 64 + (interviewerFeedback.comment?.heightWithConstrainedWidth(width: commentLabel.frame.size.width, font: commentLabel.font) ?? 0.0)
    }

}
