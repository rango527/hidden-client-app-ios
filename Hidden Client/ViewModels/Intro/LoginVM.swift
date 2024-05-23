//
//  LoginVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class LoginVM: RootVM {
    var email = BehaviorRelay(value: "")
    var password = BehaviorRelay(value: "")
    var validInput = BehaviorRelay(value: false)
    
    override init() {
        super.init()
    }
    
    override func bind() {
        Observable.combineLatest(email.asObservable(), password.asObservable()).map { (email, password) -> Bool in
            guard password.count >= Constants.User.passwordMinLength else { return false }
            let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
            return emailTest.evaluate(with: email)
        }.bind(to: validInput).disposed(by: disposeBag)
    }
    
    func login(_ completion: ((User)->())? = nil) {
        let user = User()
        user.email = email.value
        user.password = password.value
        
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.login(user)).subscribeOn(MainScheduler.instance).subscribe(onNext: { (user: User) in
            DispatchQueue.main.async {
                HUD.hide()
                
                if user.hasError() {
                    // delay(2.0) { PKHUD.flashOnTop(with: user.getErrorMessage(), UIColor.hcRed) }
                    PKHUD.flashOnTop(with: user.getErrorMessage(), UIColor.hcRed)
                } else {
                    completion?(user)
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
