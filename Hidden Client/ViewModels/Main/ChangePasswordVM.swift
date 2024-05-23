//
//  ChangePasswordVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class ChangePasswordVM: RootVM {
    
    var password = BehaviorRelay(value: "")
    var newPassword = BehaviorRelay(value: "")
    var confirmPassword = BehaviorRelay(value: "")
    var validInput = BehaviorRelay(value: false)
    
    override init() {
        super.init()
    }
    
    override func bind() {
        Observable.combineLatest(password.asObservable(), newPassword.asObservable(), confirmPassword.asObservable()).map { (old, new, confirm) -> Bool in
            guard new.length == confirm.length else { return false }
            return old.length >= Constants.User.passwordMinLength &&
                    new.length >= Constants.User.passwordMinLength &&
                    confirm.length >= Constants.User.passwordMinLength
        }.bind(to: validInput).disposed(by: disposeBag)
    }
    
    func resetPassword(_ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.resetPassword(password.value, newPassword.value)).subscribeOn(MainScheduler.instance).subscribe(onNext: { (response: Model) in
            DispatchQueue.main.async {
                HUD.hide()

                if response.hasError() {
                    PKHUD.flashOnTop(with: response.getErrorMessage(), UIColor.hcRed)
                } else {
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
