//
//  JobSettingVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/7/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD
import RxDataSources

typealias SettingSection = Constants.SettingsTableView.SettingSection

extension SettingSection: SectionModelType {
    typealias Item = HClient

    init(original: SettingSection, items: [Item]) {
        self = original
        self.items = items
    }
}

class JobSettingVM: RootVM {
    var jobId: String!
    var item = BehaviorRelay(value: JobSetting())
    var usersManagers = BehaviorRelay(value: [HClient]())
    var selectedRole = BehaviorRelay(value: "")
    var jobSettingSections: [SettingSection]!

    override init() {
        super.init()
    }

    func getJobSettings(_ id: String) {
        jobId = id
        APIManager.getObject(.getJobSettings(jobId)).subscribe(onNext: { [weak self] (setting: JobSetting) in
            self?.item.accept(setting)
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }

    func getUserManagers() {
        guard item.value.userManagers != nil else {return}
        self.usersManagers.accept(item.value.userManagers!)
    }

    func getJobRoleSection(setting: JobSetting)  -> [SettingSection]{
        let emptyRoles = [HClient]()
        let sections: [Constants.SettingsTableView.SettingSection] =
            [SettingSection(header: "Shortlist Review Type", items: [HClient()]),
             SettingSection(header: Constants.JobSettings.RoleTypes.submissionReviewer.typeValue, items: setting.submReviewerRoles ?? emptyRoles),
             SettingSection(header: Constants.JobSettings.RoleTypes.interviewer.typeValue, items: setting.interviewerRoles ?? emptyRoles),
             SettingSection(header: Constants.JobSettings.RoleTypes.interviewAdvancer.typeValue, items: setting.intAdvancerRoles ?? emptyRoles),
             SettingSection(header: Constants.JobSettings.RoleTypes.offerManager.typeValue, items: setting.offerManagerRoles ?? emptyRoles)
        ]
        return sections
    }
}
