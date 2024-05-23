//
//  InterviewTimelineCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 4/20/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol InterviewTimelineCellDelegate: class {
    func nudgeForFeedback(_ feedback: InterviewParticipant)
    func giveFeedback(_ feedback: InterviewParticipant)
}

class InterviewTimelineCellView: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var contentScrollView: UIScrollView!
    @IBOutlet weak var noFeedbackStackView: UIStackView!
    @IBOutlet weak var noFeedbackContentScrollView: UIScrollView!

    weak var delegate: InterviewTimelineCellDelegate?
    var interviewerFeedback: InterviewParticipant!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cornerRadius = 10.0
        self.contentView.cornerRadius = 10.0
        
    }

  
    override func prepareForReuse() {
        super.prepareForReuse()

    }

    func setupCell(with feedback: InterviewParticipant, interview: InterviewTimeline) {
        nameLabel.text = feedback.clientFullName
        avatarImageView.setImage(with: feedback.avatar, key: .client(feedback.clientId))
        if interviewerFeedback.feedbackSubmitted == true {
                   self.contentScrollView.isHidden = false
                   self.noFeedbackContentScrollView.isHidden = true
                   self.stackView.removeAllArrangedSubviews()
                   self.stackView.translatesAutoresizingMaskIntoConstraints = false

                   stackView.distribution = .equalSpacing
                   stackView.spacing = 10

                   if let questions = interviewerFeedback.questions {
                       questions.forEach({ (item) in
                           let itemView = TimelineFeedbackQuestionView.fromNib() as! TimelineFeedbackQuestionView
                           itemView.setupView(with: item)
                           self.stackView.addArrangedSubview(itemView)
                       })
                   }

                   let infoView = TimelineFeedbackCommentView.fromNib() as! TimelineFeedbackCommentView
                   infoView.setupView(with: interviewerFeedback)
                   self.stackView.addArrangedSubview(infoView)

                   DispatchQueue.main.async {
                       self.stackView.leadingAnchor.constraint(equalTo: self.contentScrollView.leadingAnchor).isActive = true
                       self.stackView.trailingAnchor.constraint(equalTo: self.contentScrollView.trailingAnchor).isActive = true
                       self.stackView.topAnchor.constraint(equalTo: self.contentScrollView.topAnchor).isActive = true
                       self.stackView.bottomAnchor.constraint(equalTo: self.contentScrollView.bottomAnchor).isActive = true
                       // this is important for scrolling
                       self.stackView.widthAnchor.constraint(equalTo: self.contentScrollView.widthAnchor).priority = UILayoutPriority(999)
                       self.stackView.widthAnchor.constraint(equalTo: self.contentScrollView.widthAnchor).isActive = true
                   }
               } else {
                   self.noFeedbackContentScrollView.isHidden = false
                   self.contentScrollView.isHidden = true
                   self.noFeedbackStackView.removeAllArrangedSubviews()
                   self.noFeedbackStackView.translatesAutoresizingMaskIntoConstraints = false

                   stackView.distribution = .equalSpacing
                   stackView.spacing = 20

                   let spaceView1 = UIView(frame: CGRect(x: 0, y: 0, width: self.noFeedbackStackView.frame.size.width, height: 10))
                   spaceView1.backgroundColor = .clear
                   self.noFeedbackStackView.addArrangedSubview(spaceView1)

                   let font = UIFont.avenirOblique(18)
                   let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.noFeedbackStackView.frame.size.width - 40, height: 200))
                   textLabel.numberOfLines = 0
                   textLabel.textAlignment = .center
                   textLabel.font = font
                   textLabel.textColor = UIColor.init(hex: "EAE5E5")
                   self.noFeedbackStackView.addArrangedSubview(textLabel)

                   let spaceView2 = UIView(frame: CGRect(x: 0, y: 0, width: self.noFeedbackStackView.frame.size.width, height: 20))
                   spaceView2.backgroundColor = .clear
                   self.noFeedbackStackView.addArrangedSubview(spaceView2)

                   let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.noFeedbackStackView.frame.size.width - 100, height: 60))
                   button.cornerRadius = 15.0
                   self.noFeedbackStackView.addArrangedSubview(button)

                   if interviewerFeedback.clientIsCurrentUser ?? false {
                       textLabel.text = "You haven't left feedback yet!"
                       button.backgroundColor = .hcRed
                       button.setTitle("GIVE FEEDBACK", for: .normal)
                       button.addTarget(self, action: #selector(onGiveFeedback(_:)), for: .touchUpInside)
                   } else {
                       textLabel.text = "Waiting for feedback"
                       button.backgroundColor = .hcGreen
                       button.setTitle("NUDGE FOR FEEDBACK", for: .normal)
                       button.addTarget(self, action: #selector(onNudgeForFeedback(_:)), for: .touchUpInside)
                   }

                   DispatchQueue.main.async {
                       self.noFeedbackStackView.leadingAnchor.constraint(equalTo: self.noFeedbackContentScrollView.leadingAnchor).isActive = true
                       self.noFeedbackStackView.trailingAnchor.constraint(equalTo: self.noFeedbackContentScrollView.trailingAnchor).isActive = true
                       self.noFeedbackStackView.topAnchor.constraint(equalTo: self.noFeedbackContentScrollView.topAnchor).isActive = true
                       self.noFeedbackStackView.bottomAnchor.constraint(equalTo: self.noFeedbackContentScrollView.bottomAnchor).isActive = true
                       // this is important for scrolling
                       self.noFeedbackStackView.widthAnchor.constraint(equalTo: self.noFeedbackContentScrollView.widthAnchor).isActive = true
                   }
               }
    }

    @objc func onNudgeForFeedback(_ sender: UIButton) {
        delegate?.nudgeForFeedback(self.interviewerFeedback)
    }

    @objc func onGiveFeedback(_ sender: UIButton) {
        delegate?.giveFeedback(self.interviewerFeedback)
    }

}
