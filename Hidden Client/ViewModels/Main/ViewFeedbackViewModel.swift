//
//  ViewFeedbackViewModel.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/24.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class ViewFeedbackViewModel: RootVM {
    
    let process: Process
    let timeline: Timeline

    let shortlistFeedback = BehaviorRelay(value: ShortlistFeedbackTimeline())
    let feedbacks = BehaviorRelay(value: [Feedback]())
    let feedbackReviewers = BehaviorRelay(value: [Feedback]())

    init(process: Process, timeline: Timeline) {
        self.process = process
        self.timeline = timeline
    }
    
    func getFeedback() {
        switch timeline.type ?? .started {
        case .shortlisted:
            getProcessTimelineShortlistFeedback()
        case .interview:
            getFeedbackOfInteview()
        default:
            break
        }
    }
    
    private func getProcessTimelineShortlistFeedback() {
        guard let processId = process.id else { return }

        APIManager.getObject(.getProcessTimelineShortlistFeedback(processId)).subscribe(onNext: { (item: ShortlistFeedbackTimeline) in
            DispatchQueue.main.async { HUD.hide() }
            if item.hasError() {
                DispatchQueue.main.async {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                }
            }

            DispatchQueue.main.async {
                self.shortlistFeedback.accept(item)
                self.feedbackReviewers.accept(item.reviewers ?? [Feedback]())
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
    
    private func getFeedbackOfInteview() {
        guard let processId = process.id, let interviewId = timeline.interviewId else { return }
        APIManager
            .getObject(APIManager.getFeedbackOfInterview(processId, interviewId))
            .observeOn(MainScheduler.instance)
            .map { (item: InterviewFeedback) -> [Feedback] in
                return [item.theirs, item.mine].compactMap({$0})
            }
            .catchError { (error) -> Observable<[Feedback]> in
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
                return Observable.just([])
            }
            .bind(to: feedbacks)
            .disposed(by: disposeBag)
    }
}
