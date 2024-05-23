//
//  RequestPasswordController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/12.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import Hero

final class RequestPasswordController: RootController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnRequestPassword: UIButton!
    
    let viewModel = RequestPasswordVM()
        
    override func setupRx() {
        txtEmail.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        viewModel.validInput.asObservable().bind(to: btnRequestPassword.rx.isEnabled).disposed(by: disposeBag)
    }
    
    override func sendRequest() {
        guard viewModel.validInput.value == true else {
            shakeView(txtEmail.superview)
            return
        }
        view.endEditing(true)
        viewModel.sendPasswordRequest { [weak self] _ in
            self?.txtEmail.isEnabled = false
            self?.btnRequestPassword.isEnabled = false
            self?.onGoEmailSentNotificationController()
        }
    }
    
    func onGoEmailSentNotificationController() {
        let vc = PasswordEmailSentController.fromNib()
        self.navigationController?.hero.isEnabled = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onRequestPassword(_ sender: UIButton) {
        sendRequest()
    }

}
