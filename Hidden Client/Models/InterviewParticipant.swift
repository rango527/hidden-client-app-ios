//
//  InterviewParticipant.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/24/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class InterviewParticipant: Model {

    var feedbackId: String?
    var clientId: String?
    var clientFullName: String?
    var avatar: String?
    var feedbackSubmitted: Bool?
    var interviewId: String?
    var interviewAvailabilitySubmitted: Bool?
    var clientIsCurrentUser: Bool?
    var questions: [FeedbackQuestion]?
    var comment: String?

    override func mapping(map: Map) {
        super.mapping(map: map)

        feedbackId <-                          map["feedback__feedback_id"]
        clientId <-                            map["client__client_id"]
        clientFullName <-                      map["client__full_name"]
        avatar <-                              map["asset_client__cloudinary_url"]
        feedbackSubmitted <-                   map["feedback__is_submitted"]
        interviewId <-                         map["interview__interview_id"]
        interviewAvailabilitySubmitted <-      map["interview__availability_submitted"]
        clientIsCurrentUser <-                 map["client__is_current_user"]
        questions <-                           map["feedback__questions"]
        comment <-                             map["feedback__comment"]
    }

    required init(){
        super.init()
    }

    required init?(map: Map){
        super.init(map: map)
    }

    func heightOfContent() -> CGFloat {
        var contentHeight: CGFloat = 0.0

        if self.feedbackSubmitted == true {
            if let questions = self.questions {
                questions.forEach({ (item) in
                    let itemView = TimelineFeedbackQuestionView.fromNib() as! TimelineFeedbackQuestionView
                    itemView.heightAnchor.constraint(equalToConstant: itemView.heightOfView(question: item)).isActive = true
                    contentHeight = contentHeight + itemView.heightOfView(question: item)
                })
            }

            let infoView = TimelineFeedbackCommentView.fromNib() as! TimelineFeedbackCommentView
            infoView.heightAnchor.constraint(equalToConstant: infoView.heightOfView(interviewerFeedback: self)).isActive = true
            contentHeight = contentHeight + infoView.heightOfView(interviewerFeedback: self)
        } else {
            contentHeight = 100.0
        }

        return contentHeight
    }

}
