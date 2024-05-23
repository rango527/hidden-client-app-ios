//
//  InterviewOutcomeViewController.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/04.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class InterviewOutcomeViewController: UIViewController {

    var process: Process!
    weak var actionDelegate: ProcessActionDelegate?
    
    @IBAction func onProgressNextTapped(_ sender: Any) {
        let nextStageSelectionVc = NextStageSelectionViewController.fromNib()
        nextStageSelectionVc.process = process
        nextStageSelectionVc.actionDelegate = actionDelegate
        self.navigationController?.pushViewController(nextStageSelectionVc, animated: true)
    }

    @IBAction func onRejectProcessTapped(_ sender: Any) {
       //TODO - call API to reject https://staging-api.hidden.io/docs/index.html#reject
        
        let feedbackVm = FeedbackVM(process: process, type: .interview)
        feedbackVm.rejectAfterInterview(processID: process.id ?? "") { [weak self] in
            let feedbackVc = FeedbackVC.fromNib()
            feedbackVc.viewModel = feedbackVm
            feedbackVc.actionDelegate = self?.actionDelegate
            self?.navigationController?.pushViewController(feedbackVc, animated: true)
        }
        
//        let feedbackVc = FeedbackVC.fromNib()
//        feedbackVc.viewModel = FeedbackVM(process: process, type: .interview)
//        feedbackVc.actionDelegate = actionDelegate
//        self.navigationController?.pushViewController(feedbackVc, animated: true)
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
