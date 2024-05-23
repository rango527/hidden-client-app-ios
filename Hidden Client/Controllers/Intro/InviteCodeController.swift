//
//  InviteCodeController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

final class InviteCodeController: RootController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtInviteCode: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnGetStarted: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    let viewModel = InviteCodeVM()
    
    override func setupRx() {        
        txtEmail.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        txtPassword.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        txtInviteCode.rx.text.orEmpty.bind(to: viewModel.code).disposed(by: disposeBag)
        viewModel.validInput.asObservable().bind(to: btnGetStarted.rx.isEnabled).disposed(by: disposeBag)
    }
    
    override func setupAnimations() {
        makeRoundBottomView()
    }
    
    override func sendRequest() {
        guard viewModel.validInput.value == true else {
            shakeView(txtEmail.superview)
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
    
    @IBAction func onGoLogin(_ sender: UIButton) {
        self.navigationController?.hero.navigationAnimationType = .cover(direction: .up)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onGoRequestInvite(_ sender: UIButton) {
        let requestInvitationVC = RequestInvitationController.fromNib()
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(requestInvitationVC, animated: true)
    }
}

// MARK: - Animations
extension InviteCodeController {
    func makeRoundBottomView() {
        bottomView.cornerRadius = UIScreen.main.bounds.size.width
    }
}
