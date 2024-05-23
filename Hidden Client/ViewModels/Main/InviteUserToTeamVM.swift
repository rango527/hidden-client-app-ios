//
//  InviteUserToTeamVM.swift
//  Hidden Client
//
//  Created by user on 2/14/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class InviteUserToTeamVM: RootVM {

    var jobId: String!
    var fstName = BehaviorRelay(value: "")
    var lstName = BehaviorRelay(value: "")
    var email = BehaviorRelay(value: "")

    var validInput = BehaviorRelay(value: false)

    override init() {
        super.init()
    }

    override func bind() {
        Observable.combineLatest(fstName.asObservable(), lstName.asObservable(), email.asObservable()).map { (fstName, lstName, email) -> Bool in
            let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
            return emailTest.evaluate(with: email)
        }.bind(to: validInput).disposed(by: disposeBag)
    }

    func inviteUser(_ userInfo: [String: Any], _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.invite(userInfo)).subscribe(onNext: { (item: Model) in
            DispatchQueue.main.async {
                HUD.hide()
                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    PKHUD.flashOnTop(with: "Invite Sent", UIColor.hcGreenSecond)
                    completion?()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }

}
