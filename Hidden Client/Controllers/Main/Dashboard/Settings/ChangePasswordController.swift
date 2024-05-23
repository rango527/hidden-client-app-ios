//
//  ChangePasswordController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import PKHUD

class ChangePasswordController: RootController {

    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnResetPassword: UIButton!
    
    let viewModel = ChangePasswordVM()
        
    override func setupRx() {
        txtPassword.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        txtNewPassword.rx.text.orEmpty.bind(to: viewModel.newPassword).disposed(by: disposeBag)
        txtConfirmPassword.rx.text.orEmpty.bind(to: viewModel.confirmPassword).disposed(by: disposeBag)
        viewModel.validInput.asObservable().bind(to: btnResetPassword.rx.isEnabled).disposed(by: disposeBag)
    }
    
    override func sendRequest() {
        guard viewModel.validInput.value == true else {
            shakeView(txtPassword.superview)
            return
        }
        
        view.endEditing(true)
        viewModel.resetPassword { [weak self] in
            
            self?.hero.dismissViewController(completion: {
                PKHUD.flashOnTop(with: "Password Reset")
            })
        }
    }
    
    @IBAction func onResetPassword(_ sender: Any) {
        sendRequest()
    }
}
