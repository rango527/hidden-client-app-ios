//
//  ProcessStage.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/30.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class ProcessStage: Model {

    let colors = ["BLUE": 0x000040, "GREEN": 0x66CC66, "RED": 0xE74A5F, "WHITE": 0xFFFFFF]
    let colorCodes = ["BLUE", "GREEN", "RED", "WHITE"]

    var id: String?
    var name: String?
    var stageStatus: String?
    var createdAt: String?
    var candidateApprovedAt: String?
    var interviewAgreedDate: String?
    var interviewActionRequired: InterviewActionRequired?
    var clientFeedbackSubmitted: Bool?    
    var clientHasMadeOffer: Bool?
    var candidateHasAcceptedOffer: Bool?
    var clientHasSuggestedStartDate: Bool?
    var agreedCandidateStartDate: String?
    var processNextStages: [String]?
    var feedback: Feedback?
  


    var tileText: String?
    var tileBkgColorCode: String?
    var tileIcon: String?
    var tileIconColorCode: String?
    var tileIconStyle: String?
    var tileTitleColorCode: String?
    var tileTitle: String?
    var tileButtonTitle: String?

    lazy var iconStyle: FontAwesomeStyle = {
        if tileIconStyle == "light" {
            return .light
        } else if tileIconStyle == "regular" {
            return .regular
        } else if tileIconStyle == "solid" {
            return .solid
        } else {
            return .brands
        }
    }()

    lazy var bkgColor: UIColor = {
        let color = colors[tileBkgColorCode ?? "SILVER"] ?? 0xc8c8c8
        return UIColor.colorFrom(rgb: color)
    }()

    lazy var iconColor: UIColor = {
        let color = colors[tileIconColorCode ?? "SILVER"] ?? 0xc8c8c8
        return UIColor.colorFrom(rgb: color)
    }()

    lazy var titleColor: UIColor = {
        var defaultColor: String!
        let bkgColorIndex: Int = colorCodes.firstIndex(where: {$0 == tileBkgColorCode}) ?? 0
        if bkgColorIndex == colorCodes.count - 1 {
            defaultColor = colorCodes[bkgColorIndex - 1]
        } else {
            defaultColor = colorCodes[bkgColorIndex + 1]
        }
        let color = colors[tileTitleColorCode ?? defaultColor] ?? 0x00053b
        return UIColor.colorFrom(rgb: color)
    }()

    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["process_status__process_status_id"]
        name <-         map["process_status__name"]
        stageStatus <-  map["process_stage__status"]
        createdAt <-    map["process_stage__created_at"]
        candidateApprovedAt <-          map["candidate_approved_at"]
        interviewAgreedDate <-          map["interview__agreed_date"]
        interviewActionRequired <-      map["process_stage__interview_date_action_required"]
        clientFeedbackSubmitted <-      map["client_feedback_submitted"]
        clientHasMadeOffer <-           map["client_has_made_offer"]
        candidateHasAcceptedOffer <-    map["candidate_has_accepted_offer"]
        clientHasSuggestedStartDate <-  map["client_has_suggested_start_date"]
        agreedCandidateStartDate <-     map["agreed_candidate_start_date"]
        processNextStages <-            map["process__next_stages"]
        feedback <-                     map["feedback"]
   
        

        tileText          <-            map["client__tile.text"]
        tileBkgColorCode  <-            map["client__tile.background_colour"]
        tileIcon          <-            map["client__tile.icon"]
        tileIconColorCode <-            map["client__tile.icon_colour"]
        tileIconStyle     <-            map["client__tile.icon_style"]
        tileTitleColorCode <-           map["client__tile.title_colour"]
        tileTitle         <-            map["client__tile.title"]
        tileButtonTitle   <-            map["client__tile.button"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}

extension ProcessStage {

    func getCardViewData(processStage: ProcessStage) -> ProcessCardViewData {
        var color: UIColor?
        var title: String?
        var titleColor: UIColor?
        var iconName: String?
        var iconStyle: FontAwesomeStyle?
        var iconColor: UIColor?
        var description: String?
        var buttonTitle: String?

        color = self.bkgColor
        title = self.tileTitle
        titleColor = self.titleColor
        iconName = self.tileIcon
        iconStyle = self.iconStyle
        iconColor = self.iconColor
        description = self.tileText        
        buttonTitle = (self.tileButtonTitle != nil) ? self.tileButtonTitle!.replacingOccurrences(of: "_", with: " ") : nil

        return ProcessCardViewData(color: color, title: title, titleColor: titleColor, iconName: iconName, iconStyle: iconStyle, iconColor: iconColor, description: description, buttonTitle: buttonTitle)
    }
}
