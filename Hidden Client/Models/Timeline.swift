//
//  Timeline.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/06.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper
import CoreLocation
import BonMot

enum TimelineType: String {
    case shortlisted = "SHORTLISTED"
    case interview = "INTERVIEW"
    case offer = "OFFER"
    case accepted = "ACCEPTED"
    case started = "STARTED"
}

enum InterviewerFeedbackVoteOutcome: String {
    case progress = "PROGRESS"
    case reject = "REJECT"
    case pending = "PENDING"
}

class Timeline: Model {
    
    var description: String?
    var type: TimelineType?
    var clientFeedbackSubmitted: Bool?
    var candidateFeedbackSubmitted: Bool?
    var interviewId: String?
    var dateAndTime: String?
    var clientSubmittedInterviewDates: Bool?
    var candidateSubmittedInterviewDates: Bool?
    var location: String?
    var clientNotes: String?
    var latLng: String?
    var acceptedAt: String?
    var submittedAt: String?
    var offeredAt: String?
    var agreedStartDate: String?
    var interviewParticipants: [InterviewParticipant]?
    var candidateFeedbackAverage: String?
    var candidateFeedbackDecision: InterviewerFeedbackVoteOutcome?
    var interviewerFeedbackAverage: String?
    var interviewerFeedbackDecision: InterviewerFeedbackVoteOutcome?

    //var clientFeedbackTranslated: Bool?                 //deprecated
    //var candidateFeedbackTranslated: Bool?              //deprecated
    //var feedbackId: String?                             //deprecated

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        description <-                          map["description"]
        type <-                                 map["type"]
        clientFeedbackSubmitted <-              map["client_feedback_submitted"]
        candidateFeedbackSubmitted <-       	map["candidate_feedback_submitted"]
        interviewId <-                      	map["interview_id"]
        dateAndTime <-                      	map["date_and_time"]
        clientSubmittedInterviewDates <-        map["client_submitted_interview_dates"]
        candidateSubmittedInterviewDates <- 	map["candidate_submitted_interview_dates"]
        location <-                         	map["location"]
        clientNotes <-                      	map["client_notes"]
        latLng <-                           	map["lat_lng"]
        acceptedAt <-                       	map["accepted_at"]
        submittedAt <-                      	map["submitted_at"]
        offeredAt <-                            map["offered_at"]
        agreedStartDate <-                      map["agreed_start_date"]
        interviewParticipants <-                map["interview_participants"]
        candidateFeedbackAverage <-             map["candidate_feedback_average"]
        candidateFeedbackDecision <-            map["candidate_feedback_decision"]
        interviewerFeedbackAverage <-           map["interviewer_feedback_average"]
        interviewerFeedbackDecision <-          map["interviewer_feedback_decision"]

        // deprecated
        //clientFeedbackTranslated <-             map["client_feedback_translated"]
        //candidateFeedbackTranslated <-          map["candidate_feedback_translated"]
        //feedbackId <-                           map["feedback_id"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }

    var styledCandidateFeedbackAverage: NSAttributedString {
        let text = """
        <score>\((candidateFeedbackAverage ?? "0.0").take(3))</score>
        <holder>out of 5</holder>
        """
        let scoreStyle = StringStyle(.font(UIFont.avenirHeavy(28)))
        let holderStyle = StringStyle(.font(UIFont.avenirOblique(11)))
        let style = StringStyle(
            .color(.white),
            .xmlRules([
                .style("score", scoreStyle),
                .style("holder", holderStyle)]))
        return text.styled(with: style)
    }

    var styledInterviewerFeedbackAverage: NSAttributedString {
        let text = """
        <score>\((interviewerFeedbackAverage ?? "0.0").take(3))</score>
        <holder>out of 5</holder>
        """
        let scoreStyle = StringStyle(.font(UIFont.avenirHeavy(28)))
        let holderStyle = StringStyle(.font(UIFont.avenirOblique(11)))
        let style = StringStyle(
            .color(.white),
            .xmlRules([
                .style("score", scoreStyle),
                .style("holder", holderStyle)]))
        return text.styled(with: style)
    }

    lazy var interviewDate: Date? = {
        guard let dateString = dateAndTime else { return nil }
        return HCDateFormatter.main.date(from: dateString)
    }()

    lazy var completedStatus: Bool = {
        guard let dateTime = interviewDate else { return false }
        return dateTime.timeIntervalSinceNow < -3600
    }()

    lazy var occursInPast: Bool = {
        guard let dateTime = interviewDate else { return false }
        return dateTime.timeIntervalSinceNow < 0
    }()

    lazy var occursInFuture: Bool = {
        guard let dateTime = interviewDate else { return false }
        return dateTime.timeIntervalSinceNow > 0
    }()

    lazy var coordinate: CLLocationCoordinate2D? = {
        guard let latlng = latLng?.split(separator: ",").map({Double($0) ?? 0}) else { return nil }
        return CLLocationCoordinate2D(latitude: latlng[0], longitude: latlng[1])
    }()
}

extension Timeline {
    
    func getShortlistedDate(approved: Bool) -> String? {
        guard let dateString = approved ? acceptedAt : submittedAt,
            let date = HCDateFormatter.main.date(from: dateString) else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM HH:mm"
        let values = dateFormatter.string(from: date).split(separator: " ")
        return "on \(date.dayTh) \(values[0]) at \(values[1])"
    }
    
    func getInterviewDate() -> String {
        guard let date = interviewDate else { return "Date TBC" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm MMMM yy"
        let values = dateFormatter.string(from: date).split(separator: " ")

        if completedStatus {
            return "Completed on \(date.dayTh) \(values[1]) '\(values[2])"
        } else {
            return "\(values[0]) on \(date.dayTh) \(values[1]) '\(values[2])"
        }
    }

    func getOfferDate(accepted: Bool) -> String? {
        guard let dateString = accepted ? acceptedAt : offeredAt,
            let date = HCDateFormatter.main.date(from: dateString) else { return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm EEEE"
        let values = dateFormatter.string(from: date).split(separator: " ")
        return "\(values[0]) on \(values[1])"
    }
    
    func getAgreedStartDate() -> String? {
        guard let dateString = agreedStartDate,
            let date = HCDateFormatter.main.date(from: dateString), date < Date() else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yy"
        let values = dateFormatter.string(from: date).split(separator: " ")
        return "\(date.dayTh) \(values[0]) '\(values[1])"
    }
}
