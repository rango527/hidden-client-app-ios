//
//  MembersTileView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MembersTileView: UIView {

    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var itemHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let disposeBag = DisposeBag()
    var items = BehaviorRelay(value: [CompanyPerson()])
    func setupTile(with items: [CompanyPerson]) {
        self.items.accept(items)
        setupCollectionView()
        
        self.items.asObservable().bind(to: itemsCollectionView.rx.items(cellIdentifier: "MemberTileCell")) {
            (index, item, cell: MemberTileCell) in
            cell.setupCell(with: item)
        }.disposed(by: disposeBag)
        
        self.itemsCollectionView.rx.contentOffset.subscribe(onNext: { [weak self] (offset) in
            self?.pageControl.currentPage = Int(offset.x / (self?.itemsCollectionView.bounds.width ?? UIScreen.main.bounds.width))
        }).disposed(by: disposeBag)
    }
    
    func setupCollectionView() {
        let size = CGSize(width: UIScreen.main.bounds.width - 72, height: .greatestFiniteMagnitude)
        var height: CGFloat = 100
        
        for item in items.value {
            let itemHeight = ceil(item.styledContent.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil).height)
            height = max(height, itemHeight)
        }
        
        itemHeightConstraint.constant = height + 180
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(
            width: UIScreen.main.bounds.width,
            height: itemHeightConstraint.constant
        )
        itemsCollectionView.layoutIfNeeded()
        itemsCollectionView.collectionViewLayout.invalidateLayout()
        itemsCollectionView.register(UINib(nibName: "MemberTileCell", bundle: nil), forCellWithReuseIdentifier: "MemberTileCell")
        itemsCollectionView.isPagingEnabled = true
        
        pageControl.numberOfPages = items.value.count
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
    }
}
