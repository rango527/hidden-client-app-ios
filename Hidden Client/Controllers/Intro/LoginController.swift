//
//  LoginController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import Hero
import RxSwift
import RxCocoa

final class LoginController: RootController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    let viewModel = LoginVM()

    override func setupRx() {
        txtEmail.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        txtPassword.rx.text.orEmpty.bind(to: viewModel.password).disposed(by: disposeBag)
        viewModel.validInput.asObservable().bind(to: btnSignIn.rx.isEnabled).disposed(by: disposeBag)
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
        viewModel.login { (user) in
            AppManager.shared.login(user)
        }
    }
    
    @IBAction func onLogin(_ sender: UIButton) {
        sendRequest()
    }
    
    @IBAction func onGoInviteCode(_ sender: UIButton) {
        let inviteVC = InviteCodeController.fromNib()
        inviteVC.view.layoutIfNeeded()
        self.navigationController?.hero.navigationAnimationType = .cover(direction: .up)
        self.navigationController?.pushViewController(inviteVC, animated: true)
    }
    
    @IBAction func onGoPasswordRequest(_ sender: UIButton) {
        let requestPasswordVC = RequestPasswordController.fromNib()
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(requestPasswordVC, animated: true)
    }
}

// MARK: - Animations
extension LoginController {
    func makeRoundBottomView() {
        bottomView.cornerRadius = UIScreen.main.bounds.size.width
    }
}
