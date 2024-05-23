//
//  UserManagersController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/12/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class UserManagersController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    var viewModel: JobSettingVM?
    var processViewModel: ProcessSettingVM?

    override func viewDidLoad() {
        super.viewDidLoad()

        if viewModel != nil {
            viewModel?.getUserManagers()
        }

        if processViewModel != nil {
            processViewModel?.getUserManagers()
        }

    }

    override func setupRx() {
        tblViewItems.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")
        tblViewItems.tableFooterView = UIView()

        if processViewModel != nil {
            processViewModel?.usersManagers.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "CandidateDirectoryCellView", cellType: CandidateDirectoryCellView.self)) {
                (index, item, cell) in
                cell.setupCell(with: item)
            }.disposed(by: disposeBag)
        }

        if viewModel != nil {
            viewModel?.usersManagers.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "CandidateDirectoryCellView", cellType: CandidateDirectoryCellView.self)) {
                (index, item, cell) in
                cell.setupCell(with: item)
            }.disposed(by: disposeBag)
        }
    }

}
