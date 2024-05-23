//
//  DashboardNumberView.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DashboardNumberView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var txtFilter: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var item: DashboardItem?
    weak var delegate: DashboardItemViewDelegate?
    var tiles = PublishRelay<[DashboardTile]>()
    var disposeBag = DisposeBag()
    var reloadDisposeBag = DisposeBag()
    
    private var filterPicker: UIPickerView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cellName = "DashboardNumberTileCell"
        let cellHeight = collectionView.frame.size.height
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: cellHeight, height: cellHeight)
        
        tiles.bind(to: collectionView.rx.items(cellIdentifier: cellName)) { [weak self] (index, item, cell: DashboardNumberTileCell) in
            cell.setupCell(with: item, colorScheme: self?.item?.colorScheme)
        }.disposed(by: disposeBag)
        
        setupFilterPicker()
    }
    
    private func setupFilterPicker() {
        filterPicker = UIPickerView()
        filterPicker?.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.tintColor = UIColor.hcDarkBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(onFilterSelected(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onFilterSelected(_:)))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        txtFilter.inputView = filterPicker
        txtFilter.inputAccessoryView = toolBar
    }
    
    @objc func onFilterSelected(_ sender: UIBarButtonItem) {
        txtFilter.resignFirstResponder()
        guard sender.title == "Done", let row = filterPicker?.selectedRow(inComponent: 0) else { return }
        if let key = item?.filter?.keys.map({$0})[row], let url = item?.filter?[key] {
            filterLabel.text = key
            reloadContent(with: url)
        }
    }
    
    func reloadContent(with url: String) {
        reloadDisposeBag = DisposeBag()
        APIManager
            .getList(APIManager.getDashboardTiles(url: url, cache: true))
            .observeOn(MainScheduler.instance)
            .catchErrorJustReturn([])
            .bind(to: tiles)
            .disposed(by: reloadDisposeBag)
    }
}

extension DashboardNumberView: DashboardItemViewActions {
    func setupView(with item: DashboardItem, delegate: DashboardItemViewDelegate?) {
        self.item = item
        self.delegate = delegate
        
        titleLabel.text = item.title
        
        filterLabel?.text = item.filter?.keys.first
        filterLabel?.superview?.superview?.isHidden = item.filter?.isEmpty ?? true
        
        if let keys = item.filter?.keys.map({$0}), !keys.isEmpty, let picker = filterPicker {
            Observable
                .just(keys)
                .bind(to: picker.rx.itemTitles) { $1 }
                .disposed(by: disposeBag)
            filterPicker?.selectRow(0, inComponent: 0, animated: false)
        }
        
        if let url = item.url {
            reloadContent(with: url)
        } else {
            tiles.accept(item.content ?? [])
        }
    }
}
