//
//  User.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/06.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class User: Model {
    
    var uid: String?
    var firstName: String?
    var lastName: String?
    var token: String?
    var email: String?
    var password: String?
    
    var avatar: String?
    var company: Company?
    var jobTitle: String?
    var isAdmin: Bool?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        uid <-          map["client_id"]
        firstName <-    map["first_name"]
        lastName <-     map["surname"]
        token <-        map["token"]
        email <-        map["email"]
        password <-     map["password"]
        avatar <-       map["avatar"]
        jobTitle <-     map["job_title"]
        isAdmin <-      map["is_admin"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
