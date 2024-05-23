//
//  SettingsController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/07.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import Hero

class SettingsController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var lblSettings: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    
    let viewModel = SettingsVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblViewItems.reloadData()
    }
    
    // MARK: - Prepare Rx & Animations
    override func setupRx() {
        setupTableView()
    }
    
    func setupTableView() {
        tblViewItems.register(UINib(nibName: "SettingsMenuCellView", bundle: nil), forCellReuseIdentifier: "SettingsMenuCellView")
        tblViewItems.tableFooterView = UIView()

        viewModel.items.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "SettingsMenuCellView", cellType: SettingsMenuCellView.self)) {
            (index, item, cell) in
            cell.setupCell(with: item)
        }.disposed(by: disposeBag)
        
        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            var tableIndex: Int! = indexPath.row
            if AppManager.shared.isAdmin == true {
                tableIndex = indexPath.row - 1
            }
            
            switch tableIndex {
            case -1 :
                self?.openController(CandidatesController.fromNib())
            case 0:
                self?.openController(EditProfileController.fromNib())
            case 1:
                let vc = CompanyDetailController.fromNib()
                vc.viewModel = CompanyDetailVM()
                self?.openController(vc)
            case 2:
                self?.openController(TermsController.fromNib())
            case 3:
                self?.openController(PrivacyController.fromNib())
            case 4:
                self?.openController(ChangePasswordController.fromNib())
            case 5:
                self?.logout()
            default:
                return
            }
        }).disposed(by: disposeBag)
    }
    
    func logout() {
        let alert = UIAlertController(title: "", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            AppManager.shared.logout()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func onBack(_ sender: Any) {
        hero.dismissViewController()
    }
}
