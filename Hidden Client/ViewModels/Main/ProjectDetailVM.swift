//
//  ProjectDetailVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/06.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//


import RxSwift
import RxCocoa
import PKHUD

class ProjectDetailVM: RootVM {
    
    var projectId: String?
    var item = BehaviorRelay(value: Project())
    
    convenience init(_ id: String?) {
        self.init()
        projectId = id
        getProjectDetail()
    }
    
    convenience init(_ project: Project) {
        self.init()
        projectId = project.id
        item.accept(project)
        //getProjectDetail()
    }
    
    func getProjectDetail(){
        /*guard let id = projectId else { return }
        APIManager.getObject(.getProjectDetails(id)).subscribe(onNext: { [weak self] (item: Project) in
            self?.item.accept(item)
        }, onError: { (error) in
            DispatchQueue.main.async { HUD.flash(.label((error as? APIManagerError)?.message() ?? "Error"), delay: 2.0) }
        }).disposed(by: disposeBag)*/
    }
}
