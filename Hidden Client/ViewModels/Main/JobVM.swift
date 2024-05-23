//
//  JobVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/19.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class JobVM: RootVM {
    
    var jobId: String!
    var item = BehaviorRelay(value: Job())
    var settings = BehaviorRelay(value: [Process]())

    func getJobDetail(_ id: String){
        jobId = id
        let request = APIManager.getJob(jobId)
        let cachedObject: Privacy? = CacheManager.shared.readObject(request)
        
        if cachedObject == nil {
            DispatchQueue.main.async { HUD.show(.progress) }
        }
        APIManager.getObject(request).subscribe(onNext: { [weak self] (item: Job) in
            DispatchQueue.main.async { HUD.hide() }
            self?.item.accept(item)
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }

    func getJobSettings(_ id: String){
        jobId = id
        let request = APIManager.getJobSettings(jobId)
        let cachedObject: Privacy? = CacheManager.shared.readObject(request)

        if cachedObject == nil {
            DispatchQueue.main.async { HUD.show(.progress) }
        }

        APIManager.getList(request).subscribe(onNext: { [weak self] (items: [Process]) in
            DispatchQueue.main.async { HUD.hide() }
            self?.settings.accept(items)
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }

}
