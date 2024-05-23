//
//  Conversation.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/16.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Conversation: Model {
    
    var id: String?
    var jobId: String?
    var jobTitle: String?
    var partnerName: String?
    var partnerAvatar: String?
    var messages: [Message]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-               map["conversation__conversation_id"]
        jobId <-            map["job__job_id"]
        jobTitle <-         map["job__title"]
        partnerName <-      map["talent_partner__full_name"]
        partnerAvatar <-    map["talent_partner_asset__cloudinary_url"]
        messages <-         map["messages"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
