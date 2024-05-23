//
//  ProcessDetailVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/13.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class ProcessDetailVM: RootVM {
    
    var item = BehaviorRelay(value: Process())
    var page = BehaviorRelay(value : 1)
    var timelines = BehaviorRelay(value: [Timeline]())
    
    convenience init(_ process: Process) {
        self.init()
        setProcess(process)
        getProcessDetail()
        getProcessTimeline()
    }
    
    func setProcess(_ process: Process) {
        item.accept(process)
        page.accept(process.stages?.firstIndex(where: { $0.stageStatus == Constants.ProcessStage.Status.current}) ?? 0)
    }
    
    func getProcessDetail(_ completion: ((Bool)->(Void))? = nil) {
        APIManager.getObject(.getProcessDetails(item.value.id ?? "", true)).subscribe(
            onNext: { [weak self] (process: Process) in
                completion?(true)
                self?.setProcess(process)
            }, onError: { (error) in
                completion?(false)
                DispatchQueue.main.async {
                    delay(2.0) {
                        PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                    }
                }
        }).disposed(by: disposeBag)
    }
    
    func getProcessTimeline() {
        APIManager.getList(.getProcessTimeline(item.value.id ?? "")).subscribe(
            onNext: { [weak self] (timelines: [Timeline]) in
                DispatchQueue.main.async {
                    self?.timelines.accept(timelines)
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    delay(2.0) {
                        PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                    }
                }
        }).disposed(by: disposeBag)
    }
}
