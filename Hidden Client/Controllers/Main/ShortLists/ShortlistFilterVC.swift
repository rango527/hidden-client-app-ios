//
//  ShortlistFilterVC.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ShortlistFilterVC: RootController {
    weak var viewModel: ShortListsVM?
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tblViewItems: UITableView!
    
    override func setupAnimations() {
        view.hero.modifiers = [.backgroundColor(UIColor.clear)]
        headerView.hero.modifiers = [.translate(y: -100)]
        tblViewItems.hero.modifiers = [.translate(y: -100)]
    }
    
    override func setupRx() {
        tblViewItems.register(UINib(nibName: "ShortListFilterCellView", bundle: nil), forCellReuseIdentifier: "ShortListFilterCellView")
        tblViewItems.tableFooterView = UIView()
        viewModel?.filters.asObservable().bind(to: tblViewItems.rx.items(cellIdentifier: "ShortListFilterCellView", cellType: ShortListFilterCellView.self)) { [weak self] (index, item, cell) in
            cell.setupCell(with: item, active: item == self?.viewModel?.filter.value)
        }.disposed(by: disposeBag)
        
        tblViewItems.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            if let filter = self?.viewModel?.filters.value[indexPath.row] {
                self?.viewModel?.filter.accept(filter)
                self?.tblViewItems.reloadData()
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        }).disposed(by: disposeBag)
    }
}
