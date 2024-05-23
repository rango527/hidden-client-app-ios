//
//  AddUserToRoleController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/12/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import BonMot

class AddUserToRoleController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var txtViewAdditionalUser: UITextView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var segmentSection: UIView!
    @IBOutlet weak var segmentUserScope: UISegmentedControl!

    weak var actionDelegate: JobSettingsActionDelegate?

    var jobId: String?
    var viewModel = AddUserToRoleVM()
    var selectedIndices = [Int]()
    var roleType: String!
    var bCascade: Bool = false

    let addUrl = "https://hidden.io"
    let footerHeight: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        guard let id = jobId else { return }
        if let type = Constants.JobSettings.RoleTypes(rawValue: roleType ?? "") {
            viewModel.getAvailableUserToAddJobRoles(id, role: type.typeValue)
        }
    }

    override func setupRx() {
        viewModel.validInput.asObservable().subscribe(onNext: { [weak self] status in
            self?.btnSave.isEnabled = status
            self?.btnSave.backgroundColor = status ? UIColor.hcGreenSecond : UIColor.hcLightGray
        }).disposed(by: disposeBag)

        viewModel.availableUsers.map{$0.count > 1}.subscribe(onNext: { [weak self] status in
            DispatchQueue.main.async {
                self?.lblTitle.text = self!.roleType
                if status {self?.lblTitle.text = (self?.lblTitle.text)! + "s"}
            }
        }).disposed(by: disposeBag)

        viewModel.availableUsers.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "CandidateDirectoryCellView", cellType: CandidateDirectoryCellView.self)) { (index, item, cell) in

            cell.setupCell(with: item)
            cell.checkedImageView.isHidden = false

            if self.selectedIndices.contains(index) {
                cell.checkedImageView.image = UIImage(named: "checked-icon")
            } else {
                cell.checkedImageView.image = UIImage(named: "unchecked-icon")
            }
        }.disposed(by: disposeBag)

        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            DispatchQueue.main.async {
                self?.setCellSelected(indexPath: indexPath)
                self?.tblViewItems.reloadData()
            }
        }).disposed(by: disposeBag)
    }

    func setupUI() {
        if roleType == "Shortlist Reviewer" {
            segmentSection.isHidden = true
        }
        segmentUserScope.font(name: Constants.Fonts.Avenir.book, size: 12)
        tblViewItems.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")
        tblViewItems.tableFooterView = UIView()

        let terms = "Can't find who you're looking for? They might not on Hidden yet. <adding>Add them here</adding>"
        let addStyle = StringStyle(.font(.avenirHeavy(14)), .color(.hcGreenSecond), .link(URL(string: addUrl)!))
        let style = StringStyle(.color(.hcMain), .font(.avenirMedium(14)), .alignment(.center), .xmlRules([.style("adding", addStyle)]))
        txtViewAdditionalUser.attributedText = terms.styled(with: style)
    }

    @IBAction func onSave(_ sender: UIButton) {
        guard let jobId = viewModel.jobId else { return }
        
        if roleType == "Shortlist Reviewer" {
                   bCascade = true
               }
        
        if let type = Constants.JobSettings.RoleTypes(rawValue: roleType!) {
            let selectedClients = selectedIndices.compactMap { (index) -> HClient? in
                return (0 <= index && index < viewModel.availableUsers.value.count) ? viewModel.availableUsers.value[index] : nil
            }

            let clientIds = selectedClients.compactMap({Int($0.uid!)})
            print(clientIds)
            viewModel.addUsersToJobRole(jobId, role: type.typeValue, clients: clientIds, cascade: bCascade) { [weak self] in
                DispatchQueue.main.async {
                    self?.navigationController?.popViewController(animated: true)
                    self?.actionDelegate?.onActionCompleted(message: "Permissions added")
                }
            }
        }
    }

    @IBAction func onTip(_ sender: UIButton) {
        if let type = Constants.JobSettings.RoleTypes(rawValue: roleType!) {
            let vc = HelpInfoController.fromNib()
            vc.helpInfo = type.helpDescription
            self.openController(vc)
        }
    }

    @IBAction func onSelectNewUserScope(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            bCascade = false
        } else {
            bCascade = true
        }
    }

    // MARK: - TableView Manipulation
    private func setCellSelected(indexPath: IndexPath) {
        if self.selectedIndices.contains(indexPath.row),
            let index = self.selectedIndices.firstIndex(where: {$0 == indexPath.row}) {
            self.selectedIndices.remove(at: index)
        } else {
            self.selectedIndices.append(indexPath.row)

        }
        viewModel.selectedIndices.accept(self.selectedIndices)
    }
}

extension AddUserToRoleController: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let url = URL.absoluteString
        if url == addUrl {
            let vc = InviteUserToRoleController.fromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return false
    }
}
