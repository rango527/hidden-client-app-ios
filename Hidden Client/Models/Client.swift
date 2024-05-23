//
//  Client.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class HClient: Model {
    
    var uid: String?
    var firstName: String?
    var lastName: String?
    var fullName: String?
    var email: String?
    var avatar: String?
    var jobTitle: String?
    
    var company: Company?
    
    var candidates: [Candidate]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        uid <-          map["client__client_id"]
        firstName <-    map["client__first_name"]
        lastName <-     map["client__surname"]
        fullName <-     map["client__full_name"]
        avatar <-       map["asset_client__cloudinary_url"]
        email <-        map["client__email"]
        jobTitle <-     map["client__job_title"]
        company <-      map["company"]
        candidates <-   map["candidates"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
    
    func toUser() -> User {
        let user = User()
        user.uid = uid
        user.firstName = firstName
        user.lastName = lastName
        user.avatar = avatar
        user.company = company
        user.jobTitle = jobTitle
        user.email = email
        return user
    }
}
