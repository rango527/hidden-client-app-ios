//
//  Privacy.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Privacy: Model {
    
    var content: String?
    var summary: String?
    var version: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        content <-          map["content"]
        summary <-          map["summary"]
        version <-          map["version"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
