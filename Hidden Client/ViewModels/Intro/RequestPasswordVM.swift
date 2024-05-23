//
//  RequestPasswordVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/12.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class RequestPasswordVM: RootVM {
    var email = BehaviorRelay(value: "")
    var validInput = BehaviorRelay(value: false)
    
    override init() {
        super.init()
    }
    
    override func bind() {
        email.asObservable().map { (email) -> Bool in
            let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
            return emailTest.evaluate(with: email)
        }.bind(to: validInput).disposed(by: disposeBag)
    }
    
    func sendPasswordRequest(_ completion: ((User)->())? = nil) {
        let user = User()
        user.email = email.value
        
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.sendPasswordRequest(user)).subscribeOn(MainScheduler.instance).subscribe(onNext: { (user: User) in
            DispatchQueue.main.async {
                HUD.hide()

                if user.hasError() {
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
