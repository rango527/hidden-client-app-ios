//
//  ProcessSettingsController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/16/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import BonMot
import PKHUD

protocol ProcessSettingsActionDelegate: class {
    func onActionCompleted(message: String)
}

class ProcessSettingsController: RootController {

    @IBOutlet weak var contentScrView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgViewPhoto: UIImageView!

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var txtViewAlert: UITextView!
    @IBOutlet weak var btnAlert: UIButton!

    var process: Process?
    var selectedRoleTitle: String?
    var viewModel = ProcessSettingVM()

    let manageUsersViewModel = ManageUserInProcessRoleVM()
    let settingsUrl = "https://hidden.io"
    let dataSource = RxTableViewSectionedReloadDataSource<SettingSection>(
        configureCell: { dataSource, table, idxPath, item in
            let cell = table.dequeueReusableCell(withIdentifier: "CandidateDirectoryCellView", for: idxPath) as! CandidateDirectoryCellView
            cell.setupCell(with: item)
            return cell
        }, canEditRowAtIndexPath: { dataSource, indexPath  in
            return true
        }
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func setupRx() {
        viewModel.item.subscribe(onNext: { [weak self] processSetting in
            DispatchQueue.main.async {
                HUD.hide()

                self?.reloadTableView()

                self?.imgViewPhoto.setImage(with: self?.process?.avatar, key: .candidate(self?.process!.uid))
                self?.lblName.text = processSetting.candidateFullName
                self?.lblJobTitle.text = "For: \(processSetting.jobTitle?.capitalized ?? ""), \(processSetting.cityName ?? "")"
            }
        }).disposed(by: disposeBag)

        setupTableView()
    }

    func setupUI() {
        AppManager.shared.readValue(key: Constants.Manager.isAlertReadInProcessSettings)
        if AppManager.shared.isAlertReadInProcessSettings ?? false {
            alertView.removeFromSuperview()
        }

        let alert = String(format:"Changing these settings will only affect this individual process with %@. If you want to change the settings for all candidates in process with this job, please change the  <settings>Job Settings</settings>", viewModel.item.value.candidateFullName ?? "")
        let settingStyle = StringStyle(.font(.avenirHeavy(14)), .color(.hcGreenSecond), .link(URL(string: settingsUrl)!))
        let style = StringStyle(.color(.white), .font(.avenirMedium(14)), .alignment(.left), .xmlRules([.style("settings", settingStyle)]))
        txtViewAlert.attributedText = alert.styled(with: style)
    }

    func setupTableView() {
        tblViewItems.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")

        tblViewItems.dataSource = nil
        tblViewItems.delegate = nil
        viewModel.processSettingSections.asObservable()
            .bind(to: tblViewItems.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tblViewItems.delegate = self
        tblViewItems.rx.itemDeleted.subscribe(onNext: { [weak self] (indexPath) in
            guard self?.viewModel.processSettingSections.value.isEmpty == false else { return }
            let processSettingSection = self?.viewModel.processSettingSections.value[indexPath.section]

            guard processSettingSection?.items != nil else { return }
            let roleType = Constants.ProcessSettings.responsibilityLevelTitles[indexPath.section]

            if let client = processSettingSection?.items[indexPath.row],
             let type = Constants.ProcessSettings.RoleTypes(rawValue: roleType) {
             let processId = self?.process!.id

             self?.manageUsersViewModel.deleteUserInProcessRole(processId!, role: type.typeValue, clientId: Int(client.uid!) ?? 0) { [weak self] in
                 self?.viewModel.getProcessSettings(processId!)
             }
            }
         }).disposed(by: disposeBag)
    }

    func reloadTableView() {
        self.tblViewHeightConstraint.constant = self.getTableViewContentHeight()
        self.tblViewItems.layoutIfNeeded()

        self.contentStackView.leadingAnchor.constraint(equalTo: self.contentScrView.leadingAnchor).isActive = true
        self.contentStackView.trailingAnchor.constraint(equalTo: self.contentScrView.trailingAnchor).isActive = true
        self.contentStackView.topAnchor.constraint(equalTo: self.contentScrView.topAnchor).isActive = true
        self.contentStackView.bottomAnchor.constraint(equalTo: self.contentScrView.bottomAnchor).isActive = true
        // this is important for scrolling
        self.contentStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    }

    @IBAction func OnTapAlert(sender: UIButton) {
        AppManager.shared.storeValue(true, key: Constants.Manager.isAlertReadInProcessSettings)

        UIView.animate(withDuration: 0.3) { () -> Void in
            self.alertView.removeFromSuperview()
            self.contentStackView.reloadInputViews()
            self.view.layoutIfNeeded()
        }
    }

    @objc func addUsers(sender: UIButton) {
        self.navigationController?.hero.navigationAnimationType = .fade //.push(direction: .right)

        let roleTypeIndex = sender.tag
        let processSetting = viewModel.item.value

        if processSetting.isUserManager! {
            let addUserVc = AddUserToProcessRoleController.fromNib()
            addUserVc.processId = self.process?.id
            addUserVc.actionDelegate = self
            addUserVc.roleType = Constants.ProcessSettings.responsibilityLevelTitles[roleTypeIndex]
            self.navigationController?.pushViewController(addUserVc, animated: true)
        } else {
            let userManagerVc = UserManagersController.fromNib()
            userManagerVc.processViewModel = self.viewModel
            self.navigationController?.pushViewController(userManagerVc, animated: true)
        }
    }

    @objc func helpInfo(sender: UIButton) {
        let roleTypeIndex = sender.tag

        let vc = HelpInfoController.fromNib()
        let roleType = Constants.ProcessSettings.responsibilityLevelTitles[roleTypeIndex]
        if let type = Constants.ProcessSettings.RoleTypes(rawValue: roleType) {
            vc.helpInfo = type.helpDescription
        }
        self.openController(vc)
    }

    private func getTableViewContentHeight() -> CGFloat {
        var resultHeights: Float = 0.0

        // section heights
        resultHeights = Float(Constants.SettingsTableView.headerHeight + Constants.SettingsTableView.footerHeight) * Float(viewModel.processSettingSections.value.count)

        // cell heights
        for (_, section) in viewModel.processSettingSections.value.enumerated() {
            resultHeights = resultHeights + Float(section.items.count) * Float(Constants.SettingsTableView.cellHeight)
        }

        return CGFloat(resultHeights)
    }
}

extension ProcessSettingsController: ProcessSettingsActionDelegate {
    //MARK: - ProcessSettingsActionDelegate
    func onActionCompleted(message: String) {
        guard let id = process?.id else { return }
        viewModel.getProcessSettings(id)
        delay(0.3) {
            PKHUD.flashOnTop(with: message)
        }
    }
}

extension ProcessSettingsController: UITableViewDelegate {
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = .clear
        return footerView
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingCellHeaderView.fromNib() as! SettingCellHeaderView
        if viewModel.processSettingSections.value.isEmpty == false {
            let processSettingSection = viewModel.processSettingSections.value[section]

            headerView.setupCell(with: Constants.ProcessSettings.responsibilityLevelTitles[section], itemsCount: processSettingSection.items.count)
            headerView.btnAction.addTarget(self, action: #selector(addUsers(sender:)), for: .touchUpInside)
            headerView.btnHelp.addTarget(self, action: #selector(helpInfo(sender:)), for: .touchUpInside)
            headerView.btnAction.tag = section
            headerView.btnHelp.tag = section
        }

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

extension ProcessSettingsController: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let url = URL.absoluteString
        if url == settingsUrl {
            let vc = JobSettingsController.fromNib()
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            nav.hero.navigationAnimationType = .fade
            nav.hero.isEnabled = true
            vc.jobId = process?.jobId
            present(nav, animated: true)
        }
        return false
    }
}
