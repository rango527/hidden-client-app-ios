//
//  CandidateDetailVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/03.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class CandidateDetailVM: RootVM {
    
    var candidateId: String?
    var item = BehaviorRelay(value: Candidate())
    
    convenience init(_ id: String?) {
        self.init()
        candidateId = id
        getCandidateDetail()
    }
    
    convenience init(_ candidate: Candidate, _ loadDetail: Bool? = nil) {
        self.init()
        candidateId = candidate.uid
        item.accept(candidate)
        
        if loadDetail == true {
            getCandidateDetail()
        }
    }
    
    func getCandidateDetail(){
        guard let id = candidateId else { return }
        APIManager.getObject(.getCandidateDetails(id, true)).subscribe(onNext: { [weak self] (item: Candidate) in
            self?.item.accept(item)
        }, onError: { (error) in
            delay(2.0) {
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
}
