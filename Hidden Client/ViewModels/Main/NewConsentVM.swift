//
//  NewConsentVM.swift
//  Hidden Talent
//
//  Created by Hideo Den on 2018/11/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class NewConsentVM: RootVM {
    
    var items: [Consent]!
    var page = BehaviorRelay(value: 0)
    var accepted = BehaviorRelay(value: false)
    var title = BehaviorRelay(value: "")
    var desc = BehaviorRelay(value: "")
    var subTitle = BehaviorRelay(value: "")
    var buttonTitle = BehaviorRelay(value: "")
    var switchDescription = BehaviorRelay(value: "")
    let contentVM = TermsPrivacyVM()
    
    convenience init(_ consents: [Consent]) {
        self.init()
        self.items = consents
        
        page.subscribe(onNext: { [weak self] (index) in
            guard index < (self?.items?.count ?? 0) else { return }
            guard let item = self?.items[index] else { return }
            guard let type = item.type?.rawValue else { return }
            
            self?.contentVM.getContent(type)
            
            if item.type == .terms {
                self?.title.accept("We've updated our Terms of Service.")
                self?.desc.accept("Please review the new terms below to continue")
                self?.subTitle.accept("HIDDEN TERMS OF SERVICE")
                self?.switchDescription.accept("I have read and accept the Hidden Terms of Service")
            } else {
                self?.title.accept("We've updated our Privacy Statement")
                self?.desc.accept("Please review the new privacy statement below to continue")
                self?.subTitle.accept("HIDDEN PRIVACY STATEMENT")
                self?.switchDescription.accept("I want to receive emails from Hidden about updates, news and events")
            }
            
            if item.type == .privacy {
                self?.buttonTitle.accept("CONTINUE")
            } else {
                self?.buttonTitle.accept("ACCEPT")
            }
            
            self?.accepted.accept(false)
        }).disposed(by: disposeBag)
    }
    
    func updateConsent(_ meta: String) {
        guard (items?.count ?? 0) > page.value else { return }
        let item = items[page.value]
        
        APIManager.getObject(.updateConsent(item, meta)).subscribe(onNext: { [weak self] (model: Model) in
            self?.page.accept((self?.page.value ?? 0) + 1)
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }
}
