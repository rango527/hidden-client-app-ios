//
//  AddInterviewerViewController.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/10/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import BonMot

class AddInterviewerViewController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var txtViewAdditionalUser: UITextView!
    @IBOutlet weak var btnSave: UIButton!
   

    weak var actionDelegate: ProcessActionDelegate?

    var process: Process?
    var interviewId: String!
    var viewModel = ManageUserInProcessRoleVM()
    var selectedIndices = [Int]()
    var roleType: String!

    let addUrl = "https://hidden.io"
    let footerHeight: CGFloat = 44

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

        guard let id = process?.id else { return }
        viewModel.getAvailableInterviewersToProcess(id, interviewId: interviewId)
    }

    override func setupRx() {
        viewModel.validInput.asObservable().subscribe(onNext: { [weak self] status in
            self?.btnSave.isEnabled = status
            self?.btnSave.backgroundColor = status ? UIColor.hcGreenSecond : UIColor.hcLightGray
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
        lblTitle.text = "Add interviewers to this interview with " + (process?.candidateName ?? "")
        lblTitle.sizeToFit()

        tblViewItems.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")
        tblViewItems.tableFooterView = UIView()

        let terms = "Can't find who you're looking for? <adding>Add them here</adding>"
        let addStyle = StringStyle(.font(.avenirHeavy(14)), .color(.hcGreenSecond), .link(URL(string: addUrl)!))
        let style = StringStyle(.color(.hcMain), .font(.avenirMedium(14)), .alignment(.center), .xmlRules([.style("adding", addStyle)]))
        txtViewAdditionalUser.attributedText = terms.styled(with: style)
    }

    func openJobSetting(jobId: String) {
        let vc = JobSettingsController.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.navigationAnimationType = .fade
        nav.hero.isEnabled = true
        vc.jobId = jobId
        present(nav, animated: true)
    }

    func openProcessSetting(process: Process) {
        let vc = ProcessSettingsController.fromNib()
        vc.process = process
        vc.viewModel.getProcessSettings(process.id!, { _ in
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }

    @IBAction func onSave(_ sender: UIButton) {
        guard let processId = viewModel.processId else { return }

        let selectedClients = selectedIndices.compactMap { (index) -> HClient? in
            return (0 <= index && index < viewModel.availableUsers.value.count) ? viewModel.availableUsers.value[index] : nil
        }

        let clientIds = selectedClients.compactMap({Int($0.uid!)})
        viewModel.addInterviewersToInterview(processId, interviewId: interviewId, clients: clientIds) { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
                self?.actionDelegate?.onActionCompleted(message: "New interviewer is added")
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

extension AddInterviewerViewController: UITextViewDelegate {
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let url = URL.absoluteString
        if url == addUrl {
            let alert = UIAlertController(title: "Add users to ...", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Just this process", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.openProcessSetting(process: strongSelf.process!)
                print("\(strongSelf.process?.id ?? "No process found")")
            }))

            alert.addAction(UIAlertAction(title: "All processes for this job", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.openJobSetting(jobId: strongSelf.process?.jobId ?? "")
                
            }))

            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            present(alert, animated: true)
        }
        return false
    }
}
