//
//  AddUserToProcessRoleController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/18/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import BonMot

class AddUserToProcessRoleController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var txtViewAdditionalUser: UITextView!
    @IBOutlet weak var btnSave: UIButton!


    weak var actionDelegate: ProcessSettingsActionDelegate?

    var processId: String?
    var viewModel = ManageUserInProcessRoleVM()
    var selectedIndices = [Int]()
    var roleType: String!

    let addUrl = "https://hidden.io"
    let footerHeight: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        guard let id = processId else { return }
        if let type = Constants.ProcessSettings.RoleTypes(rawValue: roleType ?? "") {
            viewModel.getAvailableUserToAddProcessRoles(id, role: type.typeValue)
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

        viewModel.availableUsers.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "CandidateDirectoryCellView", cellType: CandidateDirectoryCellView.self)) {
            (index, item, cell) in
            cell.setupCell(with: item)
            cell.checkedImageView.isHidden = false

            if self.selectedIndices.contains(index) {
                cell.checkedImageView.image = UIImage(named: "checked-icon")
            } else {
                cell.checkedImageView.image = UIImage(named: "unchecked-icon")
            }
            self.tblViewItems.layoutIfNeeded()
        }.disposed(by: disposeBag)

        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            DispatchQueue.main.async {
                self?.setCellSelected(indexPath: indexPath)
                self?.tblViewItems.reloadData()
            }
        }).disposed(by: disposeBag)
    }

    func setupUI() {
        tblViewItems.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")
        tblViewItems.tableFooterView = UIView()

        let terms = "Can't find who you're looking for? They might not on Hidden yet. <adding>Add them here</adding>"
        let addStyle = StringStyle(.font(.avenirHeavy(14)), .color(.hcGreenSecond), .link(URL(string: addUrl)!))
        let style = StringStyle(.color(.hcMain), .font(.avenirMedium(14)), .alignment(.center), .xmlRules([.style("adding", addStyle)]))
        txtViewAdditionalUser.attributedText = terms.styled(with: style)
    }

    @IBAction func onSave(_ sender: UIButton) {
        guard let processId = viewModel.processId else { return }
        guard let type = Constants.ProcessSettings.RoleTypes(rawValue: roleType!) else { return }

        let selectedClients = selectedIndices.compactMap { (index) -> HClient? in
            return (0 <= index && index < viewModel.availableUsers.value.count) ? viewModel.availableUsers.value[index] : nil
        }

        let clientIds = selectedClients.compactMap({Int($0.uid!)})
        viewModel.addUsersToProcessRole(processId, role: type.typeValue, clients: clientIds) { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
                self?.actionDelegate?.onActionCompleted(message: "Permissions added")
            }
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

extension AddUserToProcessRoleController: UITextViewDelegate {
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


