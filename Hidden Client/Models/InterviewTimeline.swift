//
//  InterviewTimeline.swift
//  Hidden Client
//
//  Created by Hideo Den on 4/16/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class InterviewTimeline: Timeline {
    var notes: String?

    // Interview Type
    var candidateFeedbackTranslation: String?
    var processStageId: String?
    var candidateFirstName: String?
    var candidateFullName: String?
    var currentClientIsInterviewAdvancer: Bool?
    var feedbackCandidateFeedbackId: String?
    var processStageProcessStatusId: Int?
    var processNextStages: [String]?
    var advanceDecisionRequired: Bool?

    override func mapping(map: Map) {
        super.mapping(map: map)
        description <-                          map["description"]
        dateAndTime <-                          map["date_and_time"]
        location <-                             map["location"]
        notes <-                                map["notes"]
        latLng <-                               map["lat_lng"]
        interviewId <-                          map["interview_id"]
        candidateFeedbackTranslation <-         map["candidate__feedback_translation"]
        processStageId <-                       map["process_stage_id"]
        candidateFirstName <-                   map["candidate__first_name"]
        candidateFullName <-                    map["candidate__full_name"]
        currentClientIsInterviewAdvancer <-     map["current_client__is_interview_advancer"]
        advanceDecisionRequired <-              map["client__advance_decision_required"]
        interviewParticipants <-                map["interviewers"]
        candidateFeedbackAverage <-             map["candidate_feedback_average"]
        candidateFeedbackDecision <-            map["candidate_feedback_decision"]
        interviewerFeedbackAverage <-           map["interviewer_feedback_average"]
        interviewerFeedbackDecision <-          map["interviewer_feedback_decision"]
        feedbackCandidateFeedbackId <-          map["feedback_candidate__feedback_id"]
        processStageProcessStatusId <-          map["process_stage__process_status_id"]
        processNextStages <-                    map["process__next_stages"]
    }

    required init(){
        super.init()
    }

    required init?(map: Map){
        super.init(map: map)
    }
}
