//
//  InviteAcceptController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//


import UIKit

final class InviteAcceptController: RootController {
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnGetStarted: UIButton!
    
    let viewModel = InviteCodeVM()
    var inviteCode: InviteCode?
        
    override func setupRx() {
        viewModel.email.accept(inviteCode?.email ?? "")
        viewModel.code.accept(inviteCode?.token ?? "")
        txtPassword.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        viewModel.validInput.asObservable().bind(to: btnGetStarted.rx.isEnabled).disposed(by: disposeBag)
    }
    
    override func sendRequest() {
        guard viewModel.validInput.value == true else {
            shakeView(txtPassword.superview)
            return
        }
        view.endEditing(true)
        let vc = SignUpController.fromNib()
        vc.viewModel = viewModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onAcceptInvitation(_ sender: UIButton) {
        sendRequest()
    }
    
}
