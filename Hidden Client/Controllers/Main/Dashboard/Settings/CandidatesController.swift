//
//  CandidatesController.swift
//  Hidden Client
//
//  Created by Hideo Den on 1/16/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import Hero

class CandidatesController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var txtSearch: UITextField!

    let viewModel = CandidatesVM()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        tblViewItems.reloadData()
    }
    
    // MARK: - Prepare Rx & Animations
    override func setupRx() {
        setupTableView()
        setupTxtField()
    }

    fileprivate func setupTxtField() {
        txtSearch.setLeftPaddingPoints(20.0)
        txtSearch.setRightPaddingPoints(20.0)
        
        txtSearch.rx.text.orEmpty.bind(to: viewModel.search).disposed(by: disposeBag)
        txtSearch.rx.controlEvent([.editingChanged, .editingDidEnd]).asObservable().subscribe(onNext: { _ in
            self.viewModel.getCandidateList(search: self.viewModel.search.value) { [weak self] in
                DispatchQueue.main.async {
                    self!.tblViewItems.reloadData()
                }
            }
        })
        .disposed(by: disposeBag)
    }
    
    fileprivate func setupTableView() {        
        tblViewItems.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")
        tblViewItems.tableFooterView = UIView()
        
        viewModel.items.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "CandidateDirectoryCellView", cellType: CandidateDirectoryCellView.self)) {
            (index, item, cell) in
            cell.setupCell(with: item)
        }.disposed(by: disposeBag)
        
        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            let candidate = self!.viewModel.items.value[indexPath.row]
            let vc = CandidateDetailVC.fromNib()
            vc.viewModel = CandidateDetailVM(candidate.uid)
            vc.isShortlist = false
            self?.openController(vc)
        }).disposed(by: disposeBag)
    }
}
