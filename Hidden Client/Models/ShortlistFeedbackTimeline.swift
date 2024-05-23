//
//  ShortlistFeedbackTimeline.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/22/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

enum ShostlistFeedbackVoteOutcome: String {
    case approved = "ACCEPTED"
    case rejected = "REJECTED"
    case pending = "PENDING"
}

class ShortlistFeedbackTimeline: Model {

    var clientSubmitted: Bool?
    var candidateSubmittedAvailability: Bool?
    var type: TimelineType?
    var processStageId: String?
    var description: String?
    var notes: String?
    var shortlistVoteOutcome: ShostlistFeedbackVoteOutcome?
    var reviewers: [Feedback]?

    override func mapping(map: Map) {
        super.mapping(map: map)
        clientSubmitted <-                   map["client_submitted"]
        candidateSubmittedAvailability <-    map["candidate_submitted_availability"]
        type <-                              map["type"]
        processStageId <-                    map["process_stage_id"]
        description <-                       map["description"]
        notes <-                             map["notes"]
        shortlistVoteOutcome <-              map["shortlist__vote_outcome"]
        reviewers <-                         map["shortlist__reviewers"]
    }

    required init(){
        super.init()
    }

    required init?(map: Map){
        super.init(map: map)
    }
}

