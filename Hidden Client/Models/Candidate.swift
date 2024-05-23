//
//  Candidate.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Candidate: Model {
    
    var uid: String?
    var name: String?
    var email: String?
    var avatar: String?
    var jobTitle1: String?
    var jobTitle2: String?
    var jobTitle3: String?
    var hiddenSays: String?
    var currentSalary: String?
    var desiredSalary: String?
    
    var processId: String?
    var city: String?
    var jobId: String?
    var jobTitle: String?
    var jobCity: String?
    
    var avatarName: String?
    var avatarImage: String?
    var avatarColor: String?
    
    var created: String?
    var updated: String?
    
    var brands: [Brand]?
    var projects: [Project]?
    var experience: [WorkExperience]?
    var skills: [Skill]?
    var feedbackQuestions: Feedback?
  
    
    lazy var color: UIColor = {
        let colors = ["blue": 0x3bb1e1, "green": 0x57ca85, "pink": 0xfc6885, "purple": 0x7b43c5, "red": 0xfc445b, "aqua": 0x0cbaba, "silver": 0xc9c9c9, "orange": 0xff7a32, "mint": 0x62fdda, "cobalt": 0x0047ab, "coral": 0xff6d50, "indigo": 0x4f69c6]
        let color = colors[avatarColor ?? "blue"] ?? 0x3bb1e1
        return UIColor.colorFrom(rgb: color)
    }()
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        uid <-          map["candidate__candidate_id"]
        name <-         map["candidate__full_name"]
        email <-        map["candidate__email"]
        avatar <-       map["asset_candidate__cloudinary_url"]
        jobTitle1 <-    map["job_title_1__name"]
        jobTitle2 <-    map["job_title_2__name"]
        jobTitle3 <-    map["job_title_3__name"]
        hiddenSays <-   map["candidate__hidden_says"]
        currentSalary <- map["candidate__salary_current"]
        desiredSalary <- map["candidate__salary_desired"]
        created <-      map["candidate__created_at"]
        updated <-      map["candidate__last_updated"]
        
        processId <-    map["process__process_id"]
        city <-         map["candidate_city__name"]
        jobId <-        map["job__job_id"]
        jobTitle <-     map["job__title"]
        jobCity <-      map["job_city__name"]
        
        avatarName <-   map["avatar__name"]
        avatarImage <-  map["avatar__image"]
        avatarColor <-  map["avatar__colour"]
        
        brands <-       map["candidate__brands"]
        projects <-     map["candidate__projects"]
        experience <-   map["candidate__work_experiences"]
        skills <-       map["candidate__skills"]
        
        feedbackQuestions <- map["feedback"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
