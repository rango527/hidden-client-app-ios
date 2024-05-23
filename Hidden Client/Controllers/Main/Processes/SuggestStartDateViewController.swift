//
//  SuggestStartDateViewController.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/05.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class SuggestStartDateViewController: RootController {

    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    
    var viewModel: SuggestStartDateViewModel!
    weak var actionDelegate: ProcessActionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hintLabel.text = "\(hintLabel.text ?? "") \(viewModel.process.candidateName?.firstName ?? "")..."
    }
    
    @IBAction func onBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSendTapped(_ sender: UIButton) {
        let text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        viewModel.suggestStartDate(with: text) {
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.actionDelegate?.onActionCompleted(message: "Start Date Sent!")
            }
        }
    }
}
