//
//  JobSetting.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/6/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper
import BonMot

class JobSetting: Model {

    var jobTitle: String?
    var cityName: String?
    var reviewType: String?
    var isUserManager: Bool?

    var userManagers: [HClient]?
    var submReviewerRoles: [HClient]?
    var interviewerRoles: [HClient]?
    var intAdvancerRoles: [HClient]?
    var offerManagerRoles: [HClient]?

    override func mapping(map: Map) {
        super.mapping(map: map)

        reviewType <-         map["review_type"]
        cityName <-           map["city__name"]
        jobTitle <-           map["job__title"]
        isUserManager <-      map["is_user_manager"]
        userManagers <-       map["user_managers"]
        interviewerRoles <-   map["roles.interviewer"]
        submReviewerRoles <-  map["roles.submission_reviewer"]
        intAdvancerRoles <-   map["roles.interview_advancer"]
        offerManagerRoles <-  map["roles.offer_manager"]
    }

    required init(){
        super.init()
    }

    required init?(map: Map){
        super.init(map: map)
    }


}
