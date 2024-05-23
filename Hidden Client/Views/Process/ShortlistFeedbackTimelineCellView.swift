//
//  ShortlistFeedbackTimelineCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/30/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ShortlistFeedbackTimelineCellView: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var outcomeLabel: HCAlignedInsetLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var contentScrollView: UIScrollView!

    var feedback: Feedback!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.cornerRadius = 10.0
        self.contentView.cornerRadius = 10.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.stackView.removeAllArrangedSubviews()
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        if feedback.submitted! == true {
            if let questions = feedback.questions {
                questions.forEach({ (item) in
                    let itemView = TimelineFeedbackQuestionView.fromNib() as! TimelineFeedbackQuestionView
                    itemView.setupView(with: item)
                    itemView.heightAnchor.constraint(equalToConstant: itemView.heightOfView(question: item)).isActive = true
                    self.stackView.addArrangedSubview(itemView)
                })
            }

            let infoView = TimelineFeedbackCommentView.fromNib() as! TimelineFeedbackCommentView
            infoView.setupView(with: feedback)
            infoView.heightAnchor.constraint(equalToConstant: infoView.heightOfView(feedback: feedback)).isActive = true
            self.stackView.addArrangedSubview(infoView)

        } else {
            let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 100))
            spaceView.backgroundColor = .clear
            self.stackView.addArrangedSubview(spaceView)

            let width = self.frame.size.width - 200
            let text = String(format:"%@ did not give feedback at shortlist stage", feedback.clientName ?? "")
            let font = UIFont.avenirOblique(18)
            let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: text.heightWithConstrainedWidth(width: width, font: font)))
            textLabel.text = text
            textLabel.numberOfLines = 0
            textLabel.textAlignment = .center
            textLabel.font = font
            textLabel.textColor = UIColor.init(hex: "EAE5E5")
            self.stackView.addArrangedSubview(textLabel)
        }

        DispatchQueue.main.async {
            self.stackView.leadingAnchor.constraint(equalTo: self.contentScrollView.leadingAnchor).isActive = true
            self.stackView.trailingAnchor.constraint(equalTo: self.contentScrollView.trailingAnchor).isActive = true
            self.stackView.topAnchor.constraint(equalTo: self.contentScrollView.topAnchor).isActive = true
            self.stackView.bottomAnchor.constraint(equalTo: self.contentScrollView.bottomAnchor).isActive = true
            // this is important for scrolling
            self.stackView.widthAnchor.constraint(equalTo: self.contentScrollView.widthAnchor).isActive = true
        }

    }

    func setupCell(with feedback: Feedback) {
        nameLabel.text = feedback.clientName
        avatarImageView.setImage(with: feedback.clientAvatar, key: .client(feedback.clientId))
        switch feedback.vote {
        case .pending:
            outcomeLabel.text = "None"
            outcomeLabel.backgroundColor = UIColor(hex: "646161")
        case .accepted:
            outcomeLabel.text = "Approve"
            outcomeLabel.backgroundColor = UIColor(hex: "66CC66")
        case .rejected:
            outcomeLabel.text = "Reject"
            outcomeLabel.backgroundColor = UIColor(hex: "E74A5F")
        default:
            outcomeLabel.text = "None"
            outcomeLabel.backgroundColor = UIColor(hex: "646161")
        }
    }
}
