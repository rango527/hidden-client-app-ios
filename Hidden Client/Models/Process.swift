//
//  Process.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/30.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Process: Model {
    
    var id: String?
    var statusId: String?
    var uid: String?
    var name: String?
    var avatar: String?
    var clientName: String?
    var clientAvatar: String?
    var candidateName: String?
    var city: String?
    var jobCity: String?
    var jobId: String?
    var jobTitle: String?
    var unread: String?
    var conversationId: String?
    var lastConversation: String?
    var stageId: String?
    var interviewId: String?
    var interviewActionRequired: InterviewActionRequired?
    var clientFeedbackSubmitted: Bool?
    var candidateFeedbackSubmitted: Bool?
    var acceptsMoreInterviews: Bool?
    var feedback: Feedback?
    var stages: [ProcessStage]?
    var isRejected: Bool?
    var rejectedBy: String?
    var isInterviewAdvancer: Bool?
    var advanceDecisionNeeded: Bool?
    var statusAfterVote: FeedbackOutcome?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-               map["process__process_id"]
        statusId <-         map["process__process_status_id"]
        uid <-              map["candidate__candidate_id"]
        name <-             map["candidate__full_name"]
        avatar <-           map["asset_candidate__cloudinary_url"]
        clientName <-       map["client__full_name"]
        clientAvatar <-     map["asset_client__cloudinary_url"]
        candidateName <-    map["candidate__full_name"]
        city <-             map["candidate_city__name"]
        jobCity <-          map["job_city__name"]
        jobId <-            map["job__job_id"]
        jobTitle <-         map["job__title"]
        conversationId <-   map["conversation__conversation_id"]
        unread <-           map["messages__number_unread"]
        lastConversation <- map["messages__last_message_created_at"]
        stageId <-          map["process_stage__process_stage_id"]
        interviewId <-      map["process__current_interview_id"]
        interviewActionRequired <-          map["process_stage__interview_date_action_required"]
        clientFeedbackSubmitted <-          map["client_feedback_submitted"]
        candidateFeedbackSubmitted <-       map["candidate_feedback_submitted"]
        acceptsMoreInterviews <-            map["process_stage__accepts_more_interviews"]
        feedback <-                         map["feedback"]
        isInterviewAdvancer <-              map["process_client__is_interview_advancer"]
        advanceDecisionNeeded <-            map["process_stage__feedback_action_required.client__advance_decision_required"]
     
        isRejected <-                       map["process__is_rejected"]
        rejectedBy <-                       map["process__rejected_by"]
        statusAfterVote <-                  map["current_outcome"]
        
        stages <-           map["process__stages"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
    
    func compareMsgReceivedWith(anotherProcess: Process) -> ComparisonResult? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssx"

        if self.lastConversation != nil, anotherProcess.lastConversation != nil,
            let currentMsgDate: Date = dateFormatter.date(from: self.lastConversation!),
            let anotherMsgDate: Date = dateFormatter.date(from: anotherProcess.lastConversation!) {
            return currentMsgDate.compare(anotherMsgDate)
        }
        return nil
    }

    func compareProcessStageWith(anotherProcess: Process) -> ComparisonResult? {
        if let currentProcessStage = self.getCurrentStage(),
            let anotherProcessStage = anotherProcess.getCurrentStage() {

            let id1 = Int(currentProcessStage.id!)!
            let id2 = Int(anotherProcessStage.id!)!
            if id1 < id2 { return .orderedAscending }
            if id1 > id2 { return .orderedDescending }
            return .orderedSame
        }

        return nil
    }

    func compareShortlistedDateWith(anotherProcess: Process) -> ComparisonResult? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssx"

        if let currentProcessStage = self.getShortlistedStage(),
            let anotherProcessStage = anotherProcess.getShortlistedStage() {

            if currentProcessStage.createdAt != nil, anotherProcessStage.createdAt != nil,
                let currentShlDate: Date = dateFormatter.date(from: currentProcessStage.createdAt!),
                let anotherShlDate: Date = dateFormatter.date(from: anotherProcessStage.createdAt!) {
                return currentShlDate.compare(anotherShlDate)
            }

        }
        return nil
    }
}

extension Process {
    func getCurrentStage() -> ProcessStage? {
        if let index = stages?.firstIndex(where: {$0.stageStatus == Constants.ProcessStage.Status.current}) {
            return stages?[index]
        }
        return nil
    }

    func getShortlistedStage() -> ProcessStage? {
        if let index = stages?.firstIndex(where: {$0.id == "1"}) {
            return stages?[index]
        }
        return nil
    }

    func filterProcesses(by: [ProcessFilter]) -> Bool {
        
        
        if let currentStageArray = stages?.filter({$0.stageStatus == Constants.ProcessStage.Status.current}) {
            let currentStage = currentStageArray[0]
            for processFilter in by {
                if processFilter.stageId == currentStage.id {
                    return true
                }
            }
        }
        return false
    }
}

class InterviewActionRequired: Model {
    var talent: Bool?
    var client: Bool?
    var candidate: Bool?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        talent <-       map["talent_partner"]
        client <-       map["client"]
        candidate <-    map["candidate"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
