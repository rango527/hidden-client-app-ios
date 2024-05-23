//
//  JobSettingsController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/7/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import PKHUD

protocol JobSettingsActionDelegate: class {
    func onActionCompleted(message: String)
}

class JobSettingsController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var lblJobTitle: UILabel!

    var jobId: String?
    var selectedRoleTitle: String?
    let viewModel = JobSettingVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let id = jobId else { return }
        viewModel.getJobSettings(id)
    }

    override func setupRx() {
        viewModel.item.subscribe(onNext: { [weak self] jobSetting in
            DispatchQueue.main.async {
                guard jobSetting.reviewType != nil else { return }

                self?.setupTableView()
                self?.lblJobTitle.text = String(format: "%@ in %@", jobSetting.jobTitle ?? "", jobSetting.cityName ?? "")
            }
        }).disposed(by: disposeBag)
    }

    func setupTableView() {
        tblViewItems.delegate = self
        tblViewItems.dataSource = nil
        tblViewItems.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")
        tblViewItems.register(UINib(nibName: "SettingsMenuCellView", bundle: nil), forCellReuseIdentifier: "SettingsMenuCellView")

        viewModel.jobSettingSections = viewModel.getJobRoleSection(setting: viewModel.item.value)

        let dataSource = RxTableViewSectionedReloadDataSource<SettingSection>(
            configureCell: { dataSource, table, idxPath, item in
                if idxPath.section == 0 {
                    let cell = table.dequeueReusableCell(withIdentifier: "SettingsMenuCellView", for: idxPath) as! SettingsMenuCellView
                    cell.setupCell(with: SettingsMenu(self.viewModel.item.value.reviewType ?? ""))
                    return cell
                } else {
                    let cell = table.dequeueReusableCell(withIdentifier: "CandidateDirectoryCellView", for: idxPath) as! CandidateDirectoryCellView
                    cell.setupCell(with: item)
                    return cell
                }
            }
        )
        dataSource.canEditRowAtIndexPath = { dataSource, indexPath  in
            if indexPath.section == 0 {
                return false
            } else {
                let processSetting = self.viewModel.item.value
                return processSetting.isUserManager!
            }
        }

        Observable.just(viewModel.jobSettingSections)
            .bind(to: tblViewItems.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tblViewItems.rx.itemDeleted.subscribe(onNext: { [weak self] (indexPath) in
            let jobSettingSection = self?.viewModel.jobSettingSections![indexPath.section]
            guard jobSettingSection?.items != nil else { return }

            let roleType = Constants.JobSettings.responsibilityLevelTitles[indexPath.section - 1]
            var roleTitle = roleType
            if (jobSettingSection?.items.count)! > 1 { roleTitle = roleTitle + "s" }

            DispatchQueue.main.async {
                if let client = jobSettingSection?.items[indexPath.row] {
                    let vc = DeleteUserInRoleController.fromNib()
                    vc.actionDelegate = self
                    vc.jobId = self?.jobId
                    vc.client = client
                    vc.roleType = roleType
                    vc.roleTitle = roleTitle
                    self?.openController(vc)
                }
            }
        }).disposed(by: disposeBag)
    }

    @objc func addUsers(sender: UIButton) {
        self.navigationController?.hero.navigationAnimationType = .fade //.push(direction: .right)

        let roleTypeIndex = sender.tag - 1
        let jobSetting = viewModel.item.value

        if jobSetting.isUserManager! {
            let addUserVc = AddUserToRoleController.fromNib()
            addUserVc.jobId = self.jobId
            addUserVc.actionDelegate = self
            addUserVc.roleType = Constants.JobSettings.responsibilityLevelTitles[roleTypeIndex]            
            self.navigationController?.pushViewController(addUserVc, animated: true)
        } else {
            let userManagerVc = UserManagersController.fromNib()
            userManagerVc.viewModel = self.viewModel
            self.navigationController?.pushViewController(userManagerVc, animated: true)
        }
    }

    @objc func helpInfo(sender: UIButton) {
        let roleTypeIndex = sender.tag - 1

        let vc = HelpInfoController.fromNib()
        if roleTypeIndex < 0 {
            vc.helpInfo = Constants.JobSettings.shortlistReviewTypeHelp
        } else {
            let roleType = Constants.JobSettings.responsibilityLevelTitles[roleTypeIndex]
            if let type = Constants.JobSettings.RoleTypes(rawValue: roleType) {
                vc.helpInfo = type.helpDescription
            }
        }
        self.openController(vc)
    }
}

extension JobSettingsController: JobSettingsActionDelegate {
    //MARK: - JobSettingsActionDelegate
    func onActionCompleted(message: String) {
        guard let id = jobId else { return }
        viewModel.getJobSettings(id)
        delay(0.3) {
            PKHUD.flashOnTop(with: message)
        }
    }
}

extension JobSettingsController: UITableViewDelegate {
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingCellHeaderView.fromNib() as! SettingCellHeaderView
        let jobSettingSection = viewModel.jobSettingSections[section]

        if section == 0 {
            headerView.btnAction.isHidden = true
            headerView.setupCell(with: "Shortlist Review Type", itemsCount: 0)
        } else {
            headerView.setupCell(with: Constants.JobSettings.responsibilityLevelTitles[section - 1], itemsCount: jobSettingSection.items.count)
        }

        headerView.btnAction.addTarget(self, action: #selector(addUsers(sender:)), for: .touchUpInside)
        headerView.btnHelp.addTarget(self, action: #selector(helpInfo(sender:)), for: .touchUpInside)
        headerView.btnAction.tag = section
        headerView.btnHelp.tag = section

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.SettingsTableView.headerHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.SettingsTableView.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constants.SettingsTableView.footerHeight
    }
}
