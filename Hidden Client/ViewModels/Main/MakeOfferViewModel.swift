//
//  MakeOfferViewModel.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/05.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class MakeOfferViewModel: RootVM {
    
    var process: Process!
    
    convenience init(_ process: Process) {
        self.init()
        self.process = process
    }
    
    func sendOffer(with text: String, _ completion: (()->())? = nil) {
        guard let id = process.id else { return }
        
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.makeOffer(id, text)).subscribe(onNext: { (item: Model) in
            DispatchQueue.main.async { HUD.hide() }

            if item.hasError() {
                DispatchQueue.main.async {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                }
            } else {
                completion?()
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
}
