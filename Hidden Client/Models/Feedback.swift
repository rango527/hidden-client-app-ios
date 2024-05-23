//
//  Feedback.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/31.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

enum FeedbackType: String {
    case submission = "SUBMISSION"
    case interview = "INTERVIEW"
}

enum FeedbackFrom: String {
    case client = "CLIENT"
    case candidate = "CANDIDATE"
}

enum FeedbackOutcome: String {
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
    case pending = "PENDING"
}

class Feedback: Model {
    
    var id: String?
    var questions: [FeedbackQuestion]?
    var vote: FeedbackOutcome?
    var comment: String?
    var from: FeedbackFrom?
    var type: FeedbackType?
    var translated: String?
    var submitted: Bool?
    var clientId: String?
    var clientName: String?
    var clientAvatar: String?

    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-               map["feedback__feedback_id"]
        questions <-        map["feedback__questions"]
        vote <-             map["feedback__vote"]
        comment <-          map["feedback__comment"]
        from <-             map["feedback__from"]
        type <-             map["feedback_type"]
        translated <-       map["feedback__translated"]
        submitted <-        map["feedback__is_submitted"]
        clientId <-         map["client__client_id"]
        clientName <-       map["client__full_name"]
        clientAvatar <-     map["asset_client__cloudinary_url"]
        
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}

class FeedbackQuestion: Model {
    
    var id: String?
    var question: String?
    var score: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["feedback_answer__feedback_answer_id"]
        question <-     map["feedback_question__question"]
        score <-        map["feedback_answer__score"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
    
    convenience init(_ question: String?) {
        self.init()
        self.question = question
    }
}

class InterviewFeedback: Model {
    
    var mine: Feedback?
    var theirs: Feedback?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        mine <-     map["MINE"]
        theirs <-   map["THEIRS"]
    }
}
