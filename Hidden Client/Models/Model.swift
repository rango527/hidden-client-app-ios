//
//  Model.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/06.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Model: Mappable {
    
    var errors: [String]?
    var status: Int?
    
    required init(){}
    
    required init?(map: Map){
        mapping(map: map)
    }
    
    func mapping(map: Map){
        errors   <- map["errors"]
        status  <- map["stat"]
    }
    
    func hasError() -> Bool {
        return (status ?? 0) > 0
    }
    
    func getErrorMessage() -> String {
        return errors?.joined(separator: "\n") ?? Constants.Error.server
    }
}
