//
//  InviteUserToRoleController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/12/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class InviteUserToRoleController: RootController {

    @IBOutlet weak var txtFstName: UITextField!
    @IBOutlet weak var txtLstName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var availableSlider: UISwitch!
    @IBOutlet weak var btnSendInvite: UIButton!

    var viewModel = InviteUserToTeamVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func setupRx() {
        txtFstName.rx.text.orEmpty.bind(to: viewModel.fstName).disposed(by: disposeBag)
        txtLstName.rx.text.orEmpty.bind(to: viewModel.lstName).disposed(by: disposeBag)
        txtEmail.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)

        viewModel.validInput.asObservable().subscribe(onNext: { [weak self] status in
            self?.btnSendInvite.isEnabled = status
            self?.btnSendInvite.backgroundColor = status ? UIColor.hcGreenSecond : UIColor.hcLightGray
        }).disposed(by: disposeBag)
    }

    func setupUI() {
        txtFstName.addLine(position: .LINE_POSITION_BOTTOM, color: .hcMain, width: 0.5)
        txtLstName.addLine(position: .LINE_POSITION_BOTTOM, color: .hcMain, width: 0.5)
        txtEmail.addLine(position: .LINE_POSITION_BOTTOM, color: .hcMain, width: 0.5)
    }

    @IBAction func onSendInvite(_ sender: UIButton) {
        let userDict: [String: Any] = ["first_name": txtFstName.text!, "surname": txtLstName.text!, "email": txtEmail.text!, "is_user_manager": String(availableSlider.isEnabled)]
        viewModel.inviteUser(userDict) { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }

    }
}
