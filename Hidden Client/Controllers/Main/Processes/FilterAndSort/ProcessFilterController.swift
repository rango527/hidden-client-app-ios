//
//  FilterController.swift
//  Hidden Client
//
//  Created by Hideo Den on 5/7/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ProcessFilterController: RootController {
    var viewModel = ProcessesVM()

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblViewItems: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func setupAnimations() {
    }

    override func setupRx() {
        tblViewItems.register(UINib(nibName: "FilterCellView", bundle: nil), forCellReuseIdentifier: "FilterCellView")
        tblViewItems.tableFooterView = UIView()

        // Filter menu contents
        viewModel.filterMenus.accept(Constants.ProcessFilter.ProcessFilterTitles)
        viewModel.filterMenus.bind(to: tblViewItems.rx.items(cellIdentifier: "FilterCellView", cellType: FilterCellView.self)) {(index, item, cell) in
            cell.setCellTitle(with: item)
        }.disposed(by: disposeBag)

        // Filter menu selection subscriber
        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            DispatchQueue.main.async {
                let type = self?.viewModel.filterMenus.value[indexPath.row]
                self?.openFilterDetail(type!)
            }
        }).disposed(by: disposeBag)

        // Individual filter menu observers
        // job filter
        viewModel.jobFilters.asObservable().subscribe(onNext: { [weak self] (filters) in
            let indexPath = IndexPath(row: 0, section: 0)
            if let cellToUse = self?.tblViewItems.cellForRow(at: indexPath) as? FilterCellView {
                cellToUse.setupJobCellContent(with: filters)
            }
        }).disposed(by: disposeBag)

        // stage filter
        viewModel.stageFilters.asObservable().subscribe(onNext: { [weak self] (filters) in
            let indexPath = IndexPath(row: 1, section: 0)
            if let cellToUse = self?.tblViewItems.cellForRow(at: indexPath) as? FilterCellView {
                cellToUse.setupExtraCellContent(with: filters, type: Constants.ProcessFilter.ProcessType.processStage)
            }
        }).disposed(by: disposeBag)

        // status filter
        viewModel.statusFilter.asObservable().subscribe(onNext: { [weak self] (filter) in
            let indexPath = IndexPath(row: 2, section: 0)
            if let cellToUse = self?.tblViewItems.cellForRow(at: indexPath) as? FilterCellView {
                cellToUse.setupSingleCellContent(with: filter, type: Constants.ProcessFilter.ProcessType.readStatus)
            }
        }).disposed(by: disposeBag)

        // sort filter
        viewModel.sortFilter.asObservable().subscribe(onNext: { [weak self] (filter) in
            let indexPath = IndexPath(row: 3, section: 0)
            if let cellToUse = self?.tblViewItems.cellForRow(at: indexPath) as? FilterCellView {
                cellToUse.setupSingleCellContent(with: filter, type: Constants.ProcessFilter.ProcessType.sortBy)
            }
        }).disposed(by: disposeBag)
    }

    func openFilterDetail(_ type: String) {
        let vc = ProcessFilterDetailController.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.hero.navigationAnimationType = .push(direction: .right)
        nav.hero.isEnabled = true
        vc.viewModel = viewModel
        vc.filterType = type

        if type == Constants.ProcessFilter.ProcessType.job {
            vc.viewModel?.setJobFilters()
            vc.filterSingle = false
        } else if type == Constants.ProcessFilter.ProcessType.processStage {()
            vc.viewModel?.extraFilterContents.accept(Constants.ProcessStage.filterTitles)
            vc.filterSingle = false
        } else if type == Constants.ProcessFilter.ProcessType.readStatus {
            vc.viewModel?.extraFilterContents.accept(Constants.ReadStatus.filterTitles)
            vc.filterSingle = true
        } else if type == Constants.ProcessFilter.ProcessType.sortBy {
            vc.viewModel?.extraFilterContents.accept(Constants.SortBy.filterTitles)
            vc.filterSingle = true
        }

        DispatchQueue.main.async {
            self.show(nav, sender: true)
        }
    }

    @IBAction func onApplyFilter(_ sender: Any) {
        self.viewModel.getProcesses(true, completion:{ result in
            self.viewModel.applyFilter()
        })
        hero.dismissViewController()
    }

    @IBAction func onClear(_ sender: Any) {
        viewModel.clearFilter()
    }

}
