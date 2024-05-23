//
//  DashboardPhotoView.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DashboardPhotoView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var item: DashboardItem?
    weak var delegate: DashboardItemViewDelegate?
    var tiles = BehaviorRelay(value: [DashboardTile]())
    var disposeBag = DisposeBag()
    
    var emptyStateView: DashboardItemEmptyView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let cellName = "DashboardPhotoTileCell"
        let cellWidth = UIScreen.main.bounds.width - 16 * 2
        let cellHeight = collectionView.frame.height
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        collectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        collectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (indexPath) in
            guard let item = self?.item, self?.tiles.value.count != 0 else { return }
            self?.delegate?.onHandleAction(item: item, info: self?.tiles.value[indexPath.row] )
        }).disposed(by: disposeBag)
        
        emptyStateView = DashboardItemEmptyView.fromNib() as? DashboardItemEmptyView
        emptyStateView.isHidden = true
        addSubview(emptyStateView)
        
        tiles.bind(to: collectionView.rx.items(cellIdentifier: cellName)) {(index, item, cell: DashboardPhotoTileCell) in
            cell.setupCell(with: item)
        }.disposed(by: disposeBag)
        
        tiles.map({!$0.isEmpty}).bind(to: emptyStateView.rx.isHidden).disposed(by: disposeBag)
    }
}

extension DashboardPhotoView: DashboardItemViewActions {
    func setupView(with item: DashboardItem, delegate: DashboardItemViewDelegate?) {
        self.item = item
        self.delegate = delegate
        
        titleLabel.text = item.title
        
        layoutIfNeeded()
        emptyStateView.frame = collectionView.frame
        emptyStateView.setupView(with: item)
        
        if let url = item.url {
            APIManager
                .getList(APIManager.getDashboardTiles(url: url, cache: true))
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn([])
                .bind(to: tiles)
                .disposed(by: disposeBag)
        } else {
            tiles.accept(item.content ?? [])
        }
    }
}
