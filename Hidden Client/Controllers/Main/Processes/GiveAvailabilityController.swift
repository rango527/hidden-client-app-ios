//
//  GiveAvailabilityController.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/08/30.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class GiveAvailabilityController: RootController {
    
    @IBOutlet weak var messageTextView: UITextView!
    
    var viewModel: GiveAvailabilityVM!
    weak var actionDelegate: ProcessActionDelegate?
    
    @IBAction func onDismiss(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSendTapped(_ sender: UIButton) {
        let text = messageTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        viewModel.sendAvailability(text: text) {
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.actionDelegate?.onActionCompleted(message: "Message Sent!")
            }
        }
    }
}
