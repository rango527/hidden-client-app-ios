//
//  CandidatesVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 1/16/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class CandidatesVM: RootVM {
    
    var items = BehaviorRelay(value: [Candidate]())
    var search = BehaviorRelay(value: "")

    override init() {
        super.init()
    }
    
    override func bind() {        
        self.getCandidateList(search: "")
    }

    func getCandidateList(search: String, completion: (()->())? = nil) {
        APIManager.getList(.getCandidateList(search)).subscribe(onNext: { [weak self] (candidates: [Candidate]) in
            self?.items.accept(candidates)
            completion?()
            }, onError: { (error) in
                DispatchQueue.main.async {
                    delay(2.0) {
                        PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                    }
                }
        }).disposed(by: disposeBag)
    }
    
}
