//
//  DashboardVM.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/12.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class DashboardVM: RootVM {

    var items = BehaviorRelay(value: [DashboardItem]())
    
    override init() {
        super.init()
        getDashboard(showLoading: false)
    }
    
    func getDashboard(showLoading: Bool = true, _ completion: ((Bool)->(Void))? = nil) {
        APIManager
            .getList(APIManager.getDashboard)
            .observeOn(MainScheduler.instance)
            .do(onCompleted: { if showLoading == true {completion?(true)} })
            .catchError({ (error) -> Observable<[DashboardItem]> in
                completion?(false)
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
                return Observable.just([])
            })
            .bind(to: items)
            .disposed(by: disposeBag)
    }
}
