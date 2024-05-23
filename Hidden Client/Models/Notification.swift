
//
//  Notification.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/26.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

enum NotificationType: String {
    case message = "new_message"
    case shortlist = "new_shortlist"
    case feedback = "give_feedback"
}

class Notification: Model {
    
    var processId: String?
    var candidateId: String?
    var jobId: String?
    var type: NotificationType?
    var recipient: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        processId <-        map["process_id"]
        candidateId <-      map["candidate_id"]
        jobId <-            map["job_id"]
        type <-             map["type"]
        recipient <-        map["recipient"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
