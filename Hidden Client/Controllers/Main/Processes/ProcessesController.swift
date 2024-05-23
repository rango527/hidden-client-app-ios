//
//  MainController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ProcessesController: RootController {
    
    @IBOutlet var emptyStateView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var filterInUseView: UIView!
    @IBOutlet weak var viewFiltersView: UIView!
    @IBOutlet weak var closeFiltersView: UIView!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var emptyStateLabel: UILabel!
    
    let viewModel = ProcessesVM()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupRx() {
        setupTableView()
    }
    
    func setupTableView() {
        tblViewItems.register(UINib(nibName: "ProcessCellView", bundle: nil), forCellReuseIdentifier: "ProcessCellView")

        viewModel.items.map {$0.count}.subscribe(onNext: { [weak self] (numberOfProcesses) in
            DispatchQueue.main.async {
                self?.updateVisibilityOfEmptyState(hidden: numberOfProcesses > 0)
                self?.showFilterInUseState()
            }
        }).disposed(by: disposeBag)

        viewModel.items.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "ProcessCellView", cellType: ProcessCellView.self)) {
            (index, item, cell) in
            cell.setupCell(with: item)
        }.disposed(by: disposeBag)

        tblViewItems.refreshControl = UIRefreshControl()
        tblViewItems.refreshControl!.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] in
            self?.viewModel.clearFilter()
            self?.viewModel.getProcesses(true, completion:{ result in
                DispatchQueue.main.async { self?.tblViewItems.refreshControl?.endRefreshing() }
            })
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            if let item = self?.viewModel.items.value[indexPath.row] {
                self?.openProcessDetail(item)
            }
        }).disposed(by: disposeBag)
    }


    func openProcessDetail(_ item: Process) {
        let vc = ProcessDetailVC.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.navigationAnimationType = .fade
        vc.viewModel = ProcessDetailVM(item)
        DispatchQueue.main.async {
            self.present(nav, animated: true)
        }
    }
    
    func updateVisibilityOfEmptyState(hidden: Bool) {
        if emptyStateView.superview == nil {
            emptyStateView.frame = tblViewItems.frame
            self.view.addSubview(emptyStateView)
        }
        
        emptyStateView.isHidden = hidden
        if !viewModel.isProcessFiltersEmpty() {
            emptyStateLabel.text = "Sorry, I can't find any processes that match those filters. Please try again"
            } else {
                emptyStateLabel.text = "You don't have any candidates in process yet... As soon as you approve a candidate from your shortlist, they'll show up here"
        }
    }

    func showFilterInUseState() {
        if viewModel.isProcessFiltersEmpty() {
            filterBtn.isHidden = false
            filterInUseView.isHidden = true
        } else {
            filterBtn.isHidden = true
            filterInUseView.isHidden = false
        }
    }

    func refreshContent(sender: UIButton) {
        activityIndicator.startAnimating()
        sender.isEnabled = false
        viewModel.clearFilter()

        viewModel.getProcesses(true, completion: { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                sender.isEnabled = true
            }
        })
    }

    private func gotoFilter() {
        let vc = ProcessFilterController.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.navigationAnimationType = .fade
        nav.hero.isEnabled = true
        vc.viewModel = self.viewModel

        DispatchQueue.main.async {
            self.present(nav, animated: true)
        }
    }

    @IBAction func onViewFilter(_ sender: UIButton) {
        gotoFilter()
    }

    @IBAction func onCloseFilters(_ sender: UIButton) {
        refreshContent(sender: sender)
    }

    @IBAction func onFilterAndSort(_ sender: UIButton) {
        gotoFilter()
    }

    @IBAction func onForceRefresh(_ sender: UIButton) {
        refreshContent(sender: sender)
    }

}
