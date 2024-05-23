//
//  NextStageSelectionViewController.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/04.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class NextStageSelectionViewController: UIViewController {

    var process: Process!
    weak var actionDelegate: ProcessActionDelegate?
    
    @IBOutlet weak var stackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (i, stageKey) in (process?.getCurrentStage()?.processNextStages ?? []).enumerated() {
            let button = UIButton(type: .roundedRect)
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            button.backgroundColor = UIColor.hcGreen
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.avenirMedium(18)
            button.setTitle(Constants.ProcessStage.selectionButtonTitles[stageKey], for: .normal)
            button.cornerRadius = 4
            button.tag = i
            button.addTarget(self, action: #selector(onActionButtonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }
    
    @IBAction func onActionButtonTapped(_ sender: UIButton) {
        
        let feedbackVm = FeedbackVM(process: process, type: .interview)
        feedbackVm.scheduleOrAdvanceToNextStep(nextStage: process.getCurrentStage()?.processNextStages?[sender.tag]) { [weak self] in
            let feedbackVc = FeedbackVC.fromNib()
            feedbackVc.viewModel = feedbackVm
            feedbackVc.actionDelegate = self?.actionDelegate
            self?.navigationController?.pushViewController(feedbackVc, animated: true)
        }
        
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
