//
//  SetPasswordController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/17.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

final class SetPasswordController: RootController {
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnGetStarted: UIButton!
    
    let viewModel = SetPasswordVM()
    var inviteCode: InviteCode?
        
    override func setupRx() {
        viewModel.email.accept(inviteCode?.email ?? "")
        viewModel.code.accept(inviteCode?.token ?? "")
        txtPassword.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        txtConfirmPassword.rx.text.orEmpty.bind(to: viewModel.confirmPassword).disposed(by: disposeBag)
        viewModel.validInput.asObservable().bind(to: btnGetStarted.rx.isEnabled).disposed(by: disposeBag)
    }
    
    override func sendRequest() {
        guard viewModel.validInput.value == true else {
            shakeView(txtPassword.superview)
            return
        }
        view.endEditing(true)
        viewModel.changeForgottenPassword { (user) in
            //AppManager.shared.login(user)
            appDelegate.updateWindow(SplashController.fromNib())
        }
    }
    
    @IBAction func onSetPassword(_ sender: UIButton) {
        sendRequest()
    }
    
}
