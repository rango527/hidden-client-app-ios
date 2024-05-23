//
//  InviteCode.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class InviteCode: Model {
    
    var email: String?
    var token: String?
    var password: String?
    var meta: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        email <-        map["email"]
        password <-     map["password"]
        token <-        map["token"]
        meta <-         map["meta"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
