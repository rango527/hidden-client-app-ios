//
//  Consent.swift
//  Hidden Talent
//
//  Created by Hideo Den on 2018/11/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

enum ConsentType: String {
    case terms = "terms"
    case privacy = "privacy"
}

class Consent: Model {
    
    var type: ConsentType?
    var oldVersion: String?
    var newVersion: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        type <-        map["type"]
        oldVersion <-  map["accepted_version"]
        newVersion <-  map["new_version"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
