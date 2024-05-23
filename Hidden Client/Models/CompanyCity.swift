//
//  CompanyCity.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class CompanyCity: Model {
    
    var id: String?
    var name: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-          map["city__city_id"]
        name <-        map["city__name"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
