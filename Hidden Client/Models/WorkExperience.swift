//
//  WorkExperience.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class WorkExperience: Model {
    
    var id: String?
    var asset: String?
    var jobTitle: String?
    var from: String?
    var to: String?
    var brand: String?
    var desc: String?
    
    lazy var durationText: String = {
        if fromText == nil {
            return "Present"
        }

        return "\(fromText ?? "") - \(toText ?? "Present")"
    }()
    
    lazy var fromText: String? = {
        if let workFrom = from, let date = HCDateFormatter.main.date(from: workFrom) {
            return HCDateFormatter.uk.string(from: date)
        }
        return nil
    }()
    
    lazy var toText: String? = {
        if let workTo = to, let date = HCDateFormatter.main.date(from: workTo) {
            return HCDateFormatter.uk.string(from: date)
        }
        return nil
    }()
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["work_experience__work_experience_id"]
        jobTitle <-     map["work_experience__job_title"]
        asset <-        map["asset__cloudinary_url"]
        from <-         map["work_experience__worked_from"]
        to <-           map["work_experience__worked_to"]
        brand <-        map["brand__name"]
        desc <-         map["work_experience__description"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
