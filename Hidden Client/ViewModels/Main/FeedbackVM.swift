//
//  FeedbackVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/08.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class FeedbackVM: RootVM {
    
    var processId: String?
    var feedbackId: String?
    var acceptance = true
    var title: String?
    var titleDescription: String?
    var items = BehaviorRelay(value: [FeedbackQuestion]())
    var page = BehaviorRelay(value: 0)
    var answers = [String: Int]()
   
    var type: FeedbackType?
    var candidate: Candidate!
    var nextStage: String?
  
    
    // called from Shortlist Feedback
    convenience init(_ accept: Bool, _ candidate: Candidate, type: FeedbackType) {
        self.init()
        self.candidate = candidate
        self.type = type
        acceptance = accept
        processId = candidate.processId
        title = "To \(accept ? "approve" : "reject") \(candidate.avatarName ?? ""), please give us some quick feedback"
        titleDescription = "*This goes to your Hidden Talent Partner and not to \(candidate.avatarName ?? "") directly"
        items.accept(candidate.feedbackQuestions?.questions ?? [])
    }
    
    // called from InterviewDetailViewController to access questions from different model
    convenience init(process: Process, interviewers: [InterviewParticipant]?, type: FeedbackType) {
        self.init()
        self.type = type
        title = "Please give us some quick feedback for \(process.candidateName ?? "the candidate")"
        titleDescription = "*This goes to your Hidden Talent Partner and not to \(process.candidateName ?? "") directly"
        if let interviewers = interviewers {
            for interviewer in interviewers {
                if let isCurrentUser = interviewer.clientIsCurrentUser {
                    if isCurrentUser {
                        items.accept(interviewer.questions ?? [])
                        feedbackId = interviewer.feedbackId ?? "Feedback ID was nil"
                        processId = process.id
                    }
                }
            }
        }
    }
    
    convenience init(process: Process?, type: FeedbackType) {
        self.init()
        self.type = type

        processId = process?.id
        title = "Please give us some quick feedback for \(process?.candidateName ?? "the candidate")"
        titleDescription = "*This goes to your Hidden Talent Partner and not to \(process?.candidateName ?? "") directly"
        if let currentStage = process?.getCurrentStage() {
            items.accept(currentStage.feedback?.questions ?? [])
            feedbackId = currentStage.feedback?.id ?? "Feedback ID was nil"
        }
    }
    
    func rateQuestion(_ question: FeedbackQuestion, _ rate: Int) {
        answers[question.id ?? ""] = rate
        page.accept(min(page.value + 1, items.value.count))
    }
    
    func rejectAfterInterview(processID: String, completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        let request = APIManager.reject(self.processId ?? "", [:])
        
        APIManager.getObject(request).subscribe(onNext: { (item: Model) in
            DispatchQueue.main.async {
                HUD.hide()

                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    completion?()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
    
    func scheduleOrAdvanceToNextStep(nextStage: String?, completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        let request = APIManager.scheduleOrAdvanceToNextStep(self.processId ?? "", ["next_step": nextStage ?? ""])
        
        APIManager.getObject(request).subscribe(onNext: { (item: Model) in
            DispatchQueue.main.async {
                HUD.hide()

                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    completion?()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
        
    }
    
    func submitVote(with comment: String?, completion: ((FeedbackOutcome)->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
       
        let request = acceptance ? APIManager.voteSubmission(self.processId ?? "", ["vote": "ACCEPTED", "answers": self.answers, "comment": comment ?? ""]) : APIManager.voteSubmission(self.processId ?? "", ["vote": "REJECTED", "answers": self.answers, "comment": comment ?? ""])
        
        APIManager.getObject(request).subscribe(onNext: { (item: Process) in
            DispatchQueue.main.async {
                HUD.hide()

                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    let submissionStatus = item.statusAfterVote ?? FeedbackOutcome.pending
                    completion?(submissionStatus)
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
    
    
    func submitFeedback(with comment: String?, completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
       
        let request = APIManager.addInterviewFeedback(self.processId ?? "", self.feedbackId ?? "", ["answers": self.answers, "comment": comment ?? ""])
        
        APIManager.getObject(request).subscribe(onNext: { (item: Model) in
            DispatchQueue.main.async {
                HUD.hide()

                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    completion?()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
}
