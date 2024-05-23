//
//  ProcessSetting.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/16/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper
import BonMot

class ProcessSetting: Model {

    var jobTitle: String?
    var cityName: String?
    var candidateFullName: String?
    var candidateAvatar: String?

    var isUserManager: Bool?

    var userManagers: [HClient]?
    var interviewerRoles: [HClient]?
    var intAdvancerRoles: [HClient]?
    var offerManagerRoles: [HClient]?

    override func mapping(map: Map) {
        super.mapping(map: map)

        candidateFullName <-  map["candidate__full_name"]
        cityName <-           map["city__name"]
        jobTitle <-           map["job__title"]
        candidateAvatar   <-  map["candidate__avatar"]
        isUserManager <-      map["is_user_manager"]
        userManagers <-       map["user_managers"]
        interviewerRoles <-   map["roles.interviewer"]
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
