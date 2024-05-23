//
//  CompanyDetailVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/13.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//


import RxSwift
import RxCocoa
import PKHUD

class CompanyDetailVM: RootVM {
    
    var item = BehaviorRelay(value: Company())
    
    override func bind() {
        getCompanyDetail()
    }
    
    func getCompanyDetail(){
        APIManager.getObject(.getCompanyDetail).subscribe(onNext: { [weak self] (item: Company) in
            self?.item.accept(item)
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }
}
