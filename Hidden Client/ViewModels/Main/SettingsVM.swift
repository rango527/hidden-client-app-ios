//
//  SettingsVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/07.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class SettingsVM: RootVM {
    
    var items = BehaviorRelay(value: [SettingsMenu]())
    
    override init() {
        super.init()
        getProfile()
    }
    
    override func bind() {
        guard let user = AppManager.shared.user else { return }

        if AppManager.shared.isAdmin == true {
            items.accept([
                SettingsMenu("Candidate Directory"),
                SettingsMenu("Edit Your Details", key: .client(user.uid), url: user.avatar),
                SettingsMenu("View Company Profile", key: .company(user.company?.id), url: user.company?.logo),
                SettingsMenu("Terms of Service"),
                SettingsMenu("Privacy Policy"),
                SettingsMenu("Reset Password"),
                SettingsMenu("Logout")
                ])
        } else {
            items.accept([
                SettingsMenu("Edit Your Details", key: .client(user.uid), url: user.avatar),
                SettingsMenu("View Company Profile", key: .company(user.company?.id), url: user.company?.logo),
                SettingsMenu("Terms of Service"),
                SettingsMenu("Privacy Policy"),
                SettingsMenu("Reset Password"),
                SettingsMenu("Logout")
                ])
        }
    }
    
    func getProfile() {
        APIManager.getObject(.getProfile).subscribe(onNext: { [weak self] (profile: HClient) in
            AppManager.shared.updateUser(profile.toUser())            
            self?.bind()
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }
    
}
