//
//  ProcessFilterDetailController.swift
//  Hidden Client
//
//  Created by Hideo Den on 5/14/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ProcessFilterDetailController: RootController {
    var viewModel: ProcessesVM?
    var filterType: String!
    var filterSingle: Bool!

    var selectedIndices = [Int]()

    private var currentFilters: [ProcessFilter]?

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var headerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headerLabel.text = filterType
    }

    override func setupRx() {
        tblViewItems.register(UINib(nibName: "FilterDetailCellView", bundle: nil), forCellReuseIdentifier: "FilterDetailCellView")
        tblViewItems.tableFooterView = UIView()

        if filterType == Constants.ProcessFilter.ProcessType.job {
            setupJobFilter()
        } else {
            setupExtraFilters()
        }
    }

    @IBAction func onDone(_ sender: Any) {
        collectFilters()
        hero.dismissViewController()
    }

    // MARK: - Filters
    func setupJobFilter() {
        currentFilters = viewModel?.jobFilters.value.filter{$0.id != nil}
        viewModel?.jobFilterContents.bind(to: tblViewItems.rx.items(cellIdentifier: "FilterDetailCellView", cellType: FilterDetailCellView.self)) { [weak self] (index, item, cell) in

            if self?.currentFilters != nil {
                let bExisting = (self?.currentFilters?.map({$0.id}).contains(item.id))
                cell.setupJobCell(with: item, active: bExisting!)
            } else {
                cell.setupJobCell(with: item, active: false)
            }

            if (self?.selectedIndices.contains(index))! {
                cell.checkedImageView.image = UIImage(named: "checked-icon")
            } else {
                cell.checkedImageView.image = UIImage(named: "unchecked-icon")
            }
        }.disposed(by: disposeBag)

        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            DispatchQueue.main.async {
                if indexPath.row == 0 {
                    // "All" - no filter
                    self?.selectedIndices.removeAll()
                    self?.currentFilters = [ProcessFilter]()
                }

                if (self?.selectedIndices.contains(0))!,
                    // if already filters are set, and "All" - no filter
                    let index = self?.selectedIndices.firstIndex(where: {$0 == 0}) {
                    let indexPth = IndexPath(row: index, section: 0)
                    self?.setCellDeSelected(indexPath: indexPth)
                }

                self?.setCellSelected(indexPath: indexPath)
                self?.tblViewItems.reloadData()
            }
        }).disposed(by: disposeBag)
    }

    func setupExtraFilters() {
        viewModel?.extraFilterContents.bind(to: tblViewItems.rx.items(cellIdentifier: "FilterDetailCellView", cellType: FilterDetailCellView.self)) { [weak self] (index, item, cell) in

            let filter: ProcessFilter?
            if self?.filterType == Constants.ProcessFilter.ProcessType.processStage {
                self?.currentFilters = self?.viewModel?.stageFilters.value.filter{$0.stage != nil}
                filter = ProcessFilter(title: self?.filterType, id: nil, job: nil, location: nil, stage: item, stageId: "\(index+1)", readStatus: nil, sortBy: nil)

                if self?.currentFilters != nil, let stageList = self?.currentFilters?.map({$0.stage}) {
                    cell.setupStageCell(with: filter!, active: stageList.contains(item))
                } else {
                    cell.setupStageCell(with: filter!, active: false)
                }
            } else if self?.filterType == Constants.ProcessFilter.ProcessType.readStatus {
                filter = ProcessFilter(title: self?.filterType, id: nil, job: nil, location: nil, stage: nil, stageId: nil, readStatus: item, sortBy: nil)

                if let currentFilter = self?.viewModel?.statusFilter.value {
                    cell.setupReadStatusCell(with: filter!, active: currentFilter.readStatus == filter!.readStatus)
                } else {
                    cell.setupReadStatusCell(with: filter!, active: false)
                }
            } else if self?.filterType == Constants.ProcessFilter.ProcessType.sortBy {
                filter = ProcessFilter(title: self?.filterType, id: nil, job: nil, location: nil, stage: nil, stageId: nil, readStatus: nil, sortBy: item)

                if let currentFilter = self?.viewModel?.sortFilter.value {
                    cell.setupSortByCell(with: filter!, active: currentFilter.sortBy == filter!.sortBy)
                } else {
                    cell.setupSortByCell(with: filter!, active: false)
                }
            }

            if (self?.selectedIndices.contains(index))! {
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

    private func collectFilters() {
        var filters = [ProcessFilter]()

        switch filterType {
        case Constants.ProcessFilter.ProcessType.job:
            // Job filter (multiple)
            selectedIndices.forEach({ index in
                if let filter = self.viewModel?.jobFilterContents.value[index] {
                    let processFilter = ProcessFilter(title: self.filterType, id: filter.id, job: filter.job, location: filter.location, stage: nil, stageId: nil, readStatus: nil, sortBy: nil)
                    filters.append(processFilter)
                }
            })
            self.viewModel?.jobFilters.accept(filters)
            break
        case Constants.ProcessFilter.ProcessType.processStage:
            // Process stage filter (multiple)
            selectedIndices.forEach({ index in
                if let filter = self.viewModel?.extraFilterContents.value[index] {
                    let processFilter = ProcessFilter(title: self.filterType, id: nil, job: nil, location: nil, stage: filter, stageId: "\(index+1)", readStatus: nil, sortBy: nil)
                    filters.append(processFilter)
                }
            })
            self.viewModel?.stageFilters.accept(filters)
            break
        case Constants.ProcessFilter.ProcessType.readStatus:
            // Read status filter (single)
            if !selectedIndices.isEmpty {
                if let filter = self.viewModel?.extraFilterContents.value[selectedIndices.first!] {
                    let statusFilter = ProcessFilter(title: self.filterType, id: nil, job: nil, location: nil, stage: nil, stageId: nil, readStatus: filter, sortBy: nil)
                    self.viewModel?.statusFilter.accept(statusFilter)
                }
            } else {
                self.viewModel?.statusFilter.accept(ProcessFilter())
            }
            break
        case Constants.ProcessFilter.ProcessType.sortBy:
            // Sort by filter (single)
            if !selectedIndices.isEmpty {
                if let filter = self.viewModel?.extraFilterContents.value[selectedIndices.first!] {
                    let sortFilter = ProcessFilter(title: self.filterType, id: nil, job: nil, location: nil, stage: nil, stageId: nil, readStatus: nil, sortBy: filter)
                    self.viewModel?.sortFilter.accept(sortFilter)
                }
            } else {
                self.viewModel?.sortFilter.accept(ProcessFilter())
            }
            break
        default:
            break
        }
    }

    // MARK: - TableView Manipulation
    private func setCellDeSelected(indexPath: IndexPath) {
        self.selectedIndices.remove(at: indexPath.row)
    }

    private func setCellSelected(indexPath: IndexPath) {
        if self.filterSingle == true {
            self.selectedIndices.removeAll()
            self.selectedIndices.append(indexPath.row)
        } else {
            if self.selectedIndices.contains(indexPath.row),
                let index = self.selectedIndices.firstIndex(where: {$0 == indexPath.row}) {
                self.selectedIndices.remove(at: index)
            } else {
                self.selectedIndices.append(indexPath.row)
            }
        }

        // only for single filters
        if self.filterSingle == true {
            if self.filterType == Constants.ProcessFilter.ProcessType.sortBy {
                self.viewModel?.sortFilter.accept(ProcessFilter())
            } else if self.filterType == Constants.ProcessFilter.ProcessType.readStatus {
                self.viewModel?.statusFilter.accept(ProcessFilter())
            }
        }
    }
}
