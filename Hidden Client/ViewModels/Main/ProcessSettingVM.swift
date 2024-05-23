//
//  ProcessSettingVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/16/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD
import RxDataSources

class ProcessSettingVM: RootVM {

    var processId: String!
    var item = BehaviorRelay(value: ProcessSetting())
    var usersManagers = BehaviorRelay(value: [HClient]())
    var selectedRole = BehaviorRelay(value: "")
    var processSettingSections = BehaviorRelay(value: [SettingSection]())

    override init() {
        super.init()
    }

    func getProcessSettings(_ id: String, _ completion: ((Bool)->(Void))? = nil) {
        processId = id
        APIManager.getObject(.getProcessSettings(processId)).subscribe(onNext: { [weak self] (setting: ProcessSetting) in
            self?.item.accept(setting)

            let processSettings = self?.getProcessRoleSection(setting: setting) ?? [SettingSection]()
            self?.processSettingSections.accept(processSettings)

            completion?(true)
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
            completion?(false)
        }).disposed(by: disposeBag)
    }

    func getUserManagers() {
        guard item.value.userManagers != nil else {return}
        self.usersManagers.accept(item.value.userManagers!)
    }

    func getProcessRoleSection(setting: ProcessSetting)  -> [SettingSection]{
        let emptyRoles = [HClient]()
        let sections: [SettingSection] = [
             SettingSection(header: Constants.ProcessSettings.RoleTypes.interviewer.typeValue, items: setting.interviewerRoles ?? emptyRoles),
             SettingSection(header: Constants.ProcessSettings.RoleTypes.interviewAdvancer.typeValue, items: setting.intAdvancerRoles ?? emptyRoles),
             SettingSection(header: Constants.ProcessSettings.RoleTypes.offerManager.typeValue, items: setting.offerManagerRoles ?? emptyRoles)]
        return sections
    }
}
