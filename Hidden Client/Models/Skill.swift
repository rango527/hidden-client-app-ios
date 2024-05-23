//
//  Skill.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Skill: Model {
    
    var id: String?
    var name: String?
    var ranking: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["skill__skill_id"]
        name <-         map["skill__name"]
        ranking <-      map["candidate_skill__ranking"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
