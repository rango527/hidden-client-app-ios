//
//  InterviewDetailVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 4/16/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD
import RxDataSources

typealias InterviewerSection = Constants.InterviewerTableView.DefaultSection

extension InterviewerSection: SectionModelType {
    typealias Item = InterviewParticipant

    init(original: InterviewerSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class InterviewDetailVM: RootVM {

    var item = BehaviorRelay(value: InterviewTimeline())
    var interviewersFeedback = BehaviorRelay(value: [InterviewParticipant]())
    var interviewParticipants = BehaviorRelay(value: [InterviewerSection]())
    var process: Process!
    var timeline: Timeline!

    convenience init(_ process: Process, timeline: Timeline) {
        self.init()
        self.process = process
        self.timeline = timeline
    }

    func getInterviewDetail(_ completion: ((Bool)->(Void))? = nil) {
        let processId = process.id ?? ""
        let interviewId = timeline.interviewId ?? ""
        APIManager.getObject(.getProcessTimelineInterview(processId, interviewId)).subscribe(
            onNext: { [weak self] (interviewTimeline: InterviewTimeline) in
                DispatchQueue.main.async {
                    self?.item.accept(interviewTimeline)

                    let interviewers = BehaviorRelay(value: interviewTimeline.interviewParticipants ?? [InterviewParticipant]())
                    self?.interviewParticipants.accept([InterviewerSection(items: interviewers.value)])
                    self?.interviewersFeedback.accept(interviewTimeline.interviewParticipants ?? [InterviewParticipant]())
                    completion?(true)
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    completion?(false)
                    delay(2.0) {
                        PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                    }
                }
        }).disposed(by: disposeBag)
    }

    func nudgeForFeedback(_ processId: String, feedbackId: String, clientId: String, _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.nudgeInterviewFeedback(processId, feedbackId, clientId)).subscribe(onNext: { (item: Model) in
            DispatchQueue.main.async {
                HUD.hide()

                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    PKHUD.flashOnTop(with: "Nudge sent", UIColor.hcGreen)
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
