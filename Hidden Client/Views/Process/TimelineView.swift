//
//  TimelineView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/14.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol TimelineViewDelegate: class {
    func onActionTapped(_ sender: UIButton)
    func onOpenMap(with timeline: Timeline)
    func onOpenViewFeedback(with timeline: Timeline)
    func onOpenViewInterview(with timeline: Timeline)
}

class TimelineView: UIView {

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var shortlistedView: UIView!
    @IBOutlet weak var shortlistedTitleLabel: UILabel!
    @IBOutlet weak var shortlistedDateLabel: UILabel!
    @IBOutlet weak var approvedDateLabel: UILabel!
    @IBOutlet weak var interviewView: UIView!
    @IBOutlet weak var interviewDateLabel: UILabel!
    @IBOutlet weak var interviewTitleLabel: UILabel!
    @IBOutlet weak var interviewersLabel: UILabel!
    @IBOutlet weak var interviewersStack: UIStackView!
    @IBOutlet weak var interviewersStackWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var interviewersCountLabel: UILabel!
    @IBOutlet weak var interviewersCountLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var candidateFeedbackScoreLabel: UILabel!
    @IBOutlet weak var candidateFeedbackStatusLabel: HCAlignedInsetLabel!
    @IBOutlet weak var interviewerFeedbackScoreLabel: UILabel!
    @IBOutlet weak var interviewerFeedbackStatusLabel: HCAlignedInsetLabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var emptyMapPinImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var offerDescriptionLabel: UILabel!

    let avatarImgViewSize: CGFloat = 20
    let avatarImgViewSpace: CGFloat = 5
    let tapMapViewGestureRecognizier = UITapGestureRecognizer()

    weak var delegate: TimelineViewDelegate?
    var timeline: Timeline!
    
    func setupView(with timeline: Timeline, candidateName: String) {
        self.timeline = timeline
        
        layoutIfNeeded()
        
        var height: CGFloat = 0
        let separatorHeight = separatorView.frame.size.height
        let actionButtonHeight = actionButton.frame.size.height
        
        switch timeline.type ?? .shortlisted {
        case .shortlisted:
            interviewView.removeFromSuperview()
            separatorView.removeFromSuperview()
            offerView.removeFromSuperview()
            shortlistedTitleLabel.text = "\(candidateName) Shortlisted"
            shortlistedDateLabel.text = timeline.getShortlistedDate(approved: false)
            approvedDateLabel.text = timeline.getShortlistedDate(approved: true)
            actionButton.setTitle("View Your Feedback", for: .normal)
            height = 121 + actionButtonHeight
        case .interview:
            shortlistedView.removeFromSuperview()
            offerView.removeFromSuperview()
            actionButton.removeFromSuperview()
            interviewDateLabel.text = timeline.getInterviewDate()
            interviewTitleLabel.text = timeline.description ?? "Interview Name TBC"
            locationLabel.text = timeline.location ?? "Location TBC"
            feedbackView.isHidden = !timeline.completedStatus

            // interviewers
            interviewersStack.removeAllArrangedSubviews()
            let visibleInterviewParticipantsNumber = 3
            let participantsCount: Int = (timeline.interviewParticipants == nil || timeline.interviewParticipants!.isEmpty) ? visibleInterviewParticipantsNumber : timeline.interviewParticipants!.count
            for index in 0..<participantsCount {
                let participant: InterviewParticipant? = (timeline.interviewParticipants == nil || timeline.interviewParticipants!.isEmpty) ? nil : timeline.interviewParticipants![index]
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: avatarImgViewSize, height: avatarImgViewSize))
                imgView.clipsToBounds = true
                imgView.cornerRadius = imgView.frame.size.width / 2
                imgView.layer.borderColor = UIColor.white.cgColor
                imgView.layer.borderWidth = 2
                if participant == nil {
                    interviewersLabel.text = "Interviewers TBC"
                    imgView.image = UIImage.imageWithColor(tintColor: .hcLightGray)
                } else {
                    interviewersLabel.text = "Interviewers"
                    imgView.setImage(with: participant!.avatar, key: .client(participant!.clientId))
                }
                interviewersStack.addArrangedSubview(imgView)
            }
            interviewersStackWidthConstraint.constant = avatarImgViewSize * CGFloat(participantsCount) - avatarImgViewSpace * CGFloat(participantsCount - 1)
            if participantsCount > 4 {
                interviewersCountLabelWidthConstraint.constant = 21
                interviewersCountLabel.text = "+" + "\(participantsCount - 4)"
            } else {
                interviewersCountLabelWidthConstraint.constant = 0
                interviewersCountLabel.text = ""
            }
            interviewersCountLabel.layoutIfNeeded()
            interviewersStack.layoutIfNeeded()

            // map
            emptyMapPinImageView.isHidden = timeline.coordinate != nil
            if let coordinate = timeline.coordinate {
                HCMap.getSnapshot(coordinate: coordinate, radius: 1000, size: mapImageView.frame.size) { [weak self] (image, _) in
                    self?.mapImageView.image = image
                }
                self.mapImageView.isUserInteractionEnabled = true
                self.tapMapViewGestureRecognizier.addTarget(self, action: #selector(onMapTapped))
                self.mapImageView.addGestureRecognizer(tapMapViewGestureRecognizier)
            } else {
                mapImageView.image = nil
            }

            // feedbacks
            candidateFeedbackStatusLabel.isHidden = (timeline.candidateFeedbackAverage == nil)
            interviewerFeedbackStatusLabel.isHidden = (timeline.interviewerFeedbackAverage == nil)

            if timeline.candidateFeedbackAverage != nil {
                candidateFeedbackScoreLabel.attributedText = timeline.styledCandidateFeedbackAverage
                //candidateFeedbackScoreLabel.setLineSpacing(lineSpacing: 1.0, lineHeightMultiple: 0.5)
            } else { candidateFeedbackScoreLabel.text = "Waiting for feedback" }

            if timeline.interviewerFeedbackAverage != nil {
                interviewerFeedbackScoreLabel.attributedText = timeline.styledInterviewerFeedbackAverage
                //interviewerFeedbackScoreLabel.setLineSpacing(lineSpacing: 1.0, lineHeightMultiple: 0.5)
            } else { interviewerFeedbackScoreLabel.text = "Waiting for feedback" }

            if timeline.candidateFeedbackDecision == nil {
                candidateFeedbackStatusLabel.text = "Decision Pending"
                candidateFeedbackStatusLabel.backgroundColor = .darkGray
            } else if timeline.candidateFeedbackDecision == .progress {
                candidateFeedbackStatusLabel.text = "Progressing"
                candidateFeedbackStatusLabel.backgroundColor = .hcGreen
            } else if timeline.candidateFeedbackDecision == .reject {
                candidateFeedbackStatusLabel.text = "Pulled Out"
                candidateFeedbackStatusLabel.backgroundColor = .hcRed
            }

            if timeline.interviewerFeedbackDecision == nil {
                interviewerFeedbackStatusLabel.text = "Decision Pending"
                interviewerFeedbackStatusLabel.backgroundColor = .darkGray
            } else if timeline.interviewerFeedbackDecision == .progress {
                interviewerFeedbackStatusLabel.text = "Progressing"
                interviewerFeedbackStatusLabel.backgroundColor = .hcGreen
            } else if timeline.interviewerFeedbackDecision == .reject {
                interviewerFeedbackStatusLabel.text = "Rejected"
                interviewerFeedbackStatusLabel.backgroundColor = .hcRed
            }
            height = 300 + separatorHeight
        case .offer, .accepted, .started:
            shortlistedView.removeFromSuperview()
            interviewView.removeFromSuperview()
            actionButton.removeFromSuperview()
            
            height = 114 + separatorHeight
            
            if timeline.type == .offer, let date = timeline.getOfferDate(accepted: false) {
                offerTitleLabel.text = "OFFER SENT!"
                offerDescriptionLabel.text = "You sent an offer to \(candidateName) at \(date)"
            }
            else if timeline.type == .accepted, let date = timeline.getOfferDate(accepted: true) {
                offerTitleLabel.text = "OFFER ACCEPTED!"
                offerDescriptionLabel.text = "\(candidateName) accepted the offer at \(date)"
                offerView.backgroundColor = UIColor.hcDarkBlue
                offerTitleLabel.textColor = UIColor.hcGreen
                offerDescriptionLabel.textColor = UIColor.white
            }
            else if timeline.type == .started, let date = timeline.getAgreedStartDate() {
                offerTitleLabel.text = "\(candidateName) STARTED!"
                offerDescriptionLabel.text = "\(candidateName) started in the job on \(date)"
                offerView.backgroundColor = UIColor.hcGreen
                offerTitleLabel.textColor = UIColor.white
                offerDescriptionLabel.textColor = UIColor.hcDarkBlue
            }
            else {
                offerView.removeFromSuperview()
                separatorView.removeFromSuperview()
                height = 0
            }
        }
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    @IBAction func onActionButtonTapped(_ sender: UIButton) {
        switch sender.title(for: .normal) ?? "" {
        case "View Feedback", "View Your Feedback":
            delegate?.onOpenViewFeedback(with: timeline)
        default:
            delegate?.onActionTapped(sender)
        }
    }
    
    @objc func onMapTapped() {
        delegate?.onOpenMap(with: timeline)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("view tapped")
        if timeline.type == TimelineType.interview {
        delegate?.onOpenViewInterview(with: timeline)
        }
    }
}
