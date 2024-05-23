//
//  Constants.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct Manager {
        static let token = "Authorization"
        static let tokenExpire = "TokenExpiration"
        static let cache = "CacheFile"
        static let defaultCache = "hidden"
        static let isAdmin = "isAdmin"
        static let isAlertReadInProcessSettings = "isAlertRead"
    }
    
    struct API {
        static let development = "https://staging-api.hidden.io/"
        static let production = "https://api.hidden.io/"
        static let logEnabled = true
    }
    
    struct Error {
        static let server = "Whoops, something's gone wrong. Please try again"
        static let unexpected = "Unexpected Error"
    }
    
    struct User {
        static let passwordMinLength = 4
    }
    
    struct Email {
        static let support = "hello@hidden.io"
    }
    
    struct TabBar {
        static let extraHeight: CGFloat = 10.0
    }

    struct SettingsTableView {
        static let headerHeight: CGFloat = 50
        static let footerHeight: CGFloat = 15
        static let cellHeight: CGFloat = 60

        struct SettingSection {
            var header: String
            var items: [HClient]
        }
    }

    struct InterviewerTableView {
        struct DefaultSection {
            var items: [InterviewParticipant]
        }
    }

    struct ShortListCard {
        static let space: CGFloat = 20.0
        static let loadingBounce: CGFloat = 0.3
        static let background: [String] = ["blue", "aqua", "cobalt", "coral", "green", "indigo", "mint", "orange", "pink", "purple", "red", "silver"]
    }
    
    struct HiddenColor {
        static let lightBlue = UIColor.colorFrom(rgb: 0x45C2F7)
        static let darkBlue = UIColor.colorFrom(rgb: 0x000040)
        static let green = UIColor.colorFrom(rgb: 0x5FCD6D)
        static let red = UIColor.colorFrom(rgb: 0xE74A5F)
        static let purple = UIColor.colorFrom(rgb: 0x7B43C5)
        static let orange = UIColor.colorFrom(rgb: 0xFF7A32)
    }
    
    struct FeedbackCell {
        static let space: CGFloat = 20.0
    }

    struct ShortlistFeedbackTimelineCell {
        static let space: CGFloat = 10.0
    }

    struct InterviewTimelineCell {
        static let space: CGFloat = 20.0
    }


    struct Fonts {
        struct Avenir {
            static let book = "Avenir-Book"
            static let roman = "Avenir-Roman"
            static let medium = "Avenir-Medium"
            static let heavy = "Avenir-Heavy"
            static let black = "Avenir-Black"
            static let oblique = "Avenir-Oblique"
            static let mediumOblique = "Avenir-MediumOblique"
        }
    }

    struct JobSettings {
        static let responsibilityLevelTitles = ["Shortlist Reviewer",
                                           "Interviewer",
                                           "Interview Advancer",
                                           "Offer Manager"]
        static let shortlistReviewTypeHelp = "The shortlist review type is the workflow that you’re following for approving or rejecting new candidate submissions. There are 3 types to choose from: Unanimity, Majority or First Choice Rules. If you want to change your workflow or find out more, please get in touch with your Talent Partner"
        static let removeUserInRoleHelp = "When removing a user from a role, you can choose to remove them from just new processes that started for a job. Or, you can remove them from new processes and existing processes."

        enum RoleTypes: String {
            case submissionReviewer = "Shortlist Reviewer"
            case interviewer = "Interviewer"
            case interviewAdvancer = "Interview Advancer"
            case offerManager = "Offer Manager"

            var typeValue: String {
                switch self {
                case .submissionReviewer: return "submission_reviewer"
                case .interviewer: return "interviewer"
                case .interviewAdvancer: return "interview_advancer"
                case .offerManager: return "offer_manager"
                }
            }

            var helpDescription: String {
                switch self {
                case .submissionReviewer: return "These are the users who receive all new candidate submissions and who are responsible for approving or rejecting them"
                case .interviewer: return "These are the users who can be added to interviews for processes associated with this job"
                case .interviewAdvancer: return "Once an interview is completed, these users are responsible for entering whether the candidate is progressing or whether they are rejected. If there are multiple Interview Advancers, only one user has to make a decision to keep things moving"
                case .offerManager: return "These users are the points of contact for gathering offer information. Users who are not Offer Managers will not see any of the offer details, nor will they be able to see any candidate’s salary on their profile, nor the salary on the job in question"
                }
            }
        }
    }

    struct ProcessSettings {
        static let responsibilityLevelTitles = ["Interviewer",
                                                "Interview Advancer",
                                                "Offer Manager"]

        enum RoleTypes: String {
            case interviewer = "Interviewer"
            case interviewAdvancer = "Interview Advancer"
            case offerManager = "Offer Manager"

            var typeValue: String {
                switch self {
                case .interviewer: return "interviewer"
                case .interviewAdvancer: return "interview_advancer"
                case .offerManager: return "offer_manager"
                }
            }

            var helpDescription: String {
                switch self {
                case .interviewer: return "These are the users who can be added to interviews for processes associated with this job"
                case .interviewAdvancer: return "Once an interview is completed, these users are responsible for entering whether the candidate is progressing or whether they are rejected. If there are multiple Interview Advancers, only one user has to make a decision to keep things moving"
                case .offerManager: return "These users are the points of contact for gathering offer information. Users who are not Offer Managers will not see any of the offer details, nor will they be able to see any candidate’s salary on their profile, nor the salary on the job in question"
                }
            }
        }
    }


    struct ProcessStage {
        
        struct Status {
            static let completed = "COMPLETE"
            static let current = "CURRENT"
            static let future = "FUTURE"
            static let skipped = "SKIPPED"
        }
        
        struct Title {
            static let shortlisted = "SHORTLISTED"
            static let firstStage = "FIRST STAGE INTERVIEW"
            static let furtherStage = "FURTHER INTERVIEWS"
            static let finalStage = "FINAL INTERVIEW"
            static let offerStage = "OFFER STAGE"
            static let accepted = "OFFER ACCEPTED STAGE"
            static let started = "STARTED"
        }
        
        struct Description {
            static let shortlistedComplete = "COMPLETE! You approved %@ on %@"
            static let waitingCandidateAvailability = "Waiting for %@'s availability.\nYou'll get a notification when we've confirmed the time/date"
            static let interviewBookedIn = "Interview booked in!\n%@"
            static let waitingCandidateFeedback = "Waiting for %@'s feedback.\nYou'll get a notification when we've received it"
            static let stageCompleted = "Stage Completed!"
            static let stageSkipped = "Stage Skipped!"
            static let candidatePulledOutOfProcess = "%@ has pulled out of the interview process"
            static let candidateRejected = "%@ has been rejected from the process"
            static let furtherStageFuture = "Don't jump the gun! Let's get through the First Stage first!"
            static let finalStageFuture = "Chill your beans! You'll have to interview"
            static let offerStageFuture = "Not so fast! You can make an offer after the next interview"
            static let waitingCandidateResponse = "Waiting for %@ to accept the offer"
            static let offerStateComplete = "%@ accepted the offer!"
            static let acceptedStageFuture = "Hold your horses! Let's get the offer to %@ first..."
            static let waitingConfirmStartDate = "Confirming start date with %@"
            static let acceptedStageComplete = "%@ will be starting on %@!"
            static let startedStageFuture = "Hold tight! I'm sure %@ will be starting with you soon..."
            static let candidateWillStart = "Hold tight! %@ is starting on %@"
            static let candidateHasStarted = "Congratulations! %@ started %"
        }
        
        struct ButtonTitle {
            static let giveFeedback = "GIVE FEEDBACK"
            static let giveInterviewAvailability = "GIVE AVAILABILITY"
            static let makeOffer = "MAKE OFFER"
            static let giveStartDate = "SUGGEST START DATE"
            static let joinInterview = "JOIN INTERVIEW"
            static let addInterviewers = "ADD INTERVIEWERS"
        }
        
        static let selectionButtonTitles = [
            "TO_FURTHER_STAGE": "Further Stage Interview",
            "TO_FINAL_STAGE": "Final Stage Interview",
            "MAKE_OFFER": "Make Offer",
            "ADD_INTERVIEW": "Add Interview"
        ]

        static let filterTitles = [
            "Shortlist Stage",
            "First Stage Interview",
            "Further Stage Interviews",
            "Final Stage Interviews",
            "Offer Stage",
            "Offer Accepted",
            "Started"
        ]
    }
    
    struct Message {
        struct SenderType {
            static let currentUser = "FROM_YOU"
            static let colleague = "FROM_COLLEAGUE"
            static let talentPartner = "FROM_TP"
        }
        
        struct AssetType {
            static let text = ""
            static let image = "IMAGE"
            static let video = "VIDEO"
            static let pdf = "PDF"
            static let document = "OTHER"
        }
    }
    
    struct TileType {
        static let text = "TEXT"
        static let image = "IMAGE"
        static let video = "VIDEO"
    }

    struct Filter {
        static let process = "PROCESS"
    }

    struct ProcessFilter {
        struct ProcessType {
            static let job = "Job"
            static let processStage = "Process Stage"
            static let readStatus = "Read Status"
            static let sortBy = "Sort By"
        }

        static let ProcessFilterTitles = [
            "Job",
            "Process Stage",
            "Read Status",
            "Sort By"
        ]
    }

    struct ReadStatus {
        static let filterTitles = [
            "Has Unread Messages",
            "Has No Unread Messages"
        ]

        static let hasUnreadStatus = "Has Unread Messages"
        static let noUnreadStatus = "Has No Unread Messages"
    }

    struct SortBy {
        static let filterTitles = [
            "Most Recent Activity",
            "Process Stage",
            "Shortlisting Date"
        ]

        static let mostRecent = "Most Recent Activity"
        static let processStage = "Process Stage"
        static let shortlistingDate = "Shortlisting Date"
    }

}

