//
//  ShortlistViewFeedbackViewController.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/31/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ShortlistViewFeedbackViewController: RootController {

    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var outcomeStatusLabel: UILabel!

    var flowLayout: HCCollectionViewFlowLayout!
    var viewModel: ViewFeedbackViewModel!
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionViewFlowLayout()
    }

    override func setupRx() {
        viewModel.getFeedback()
        
        viewModel.shortlistFeedback.bind { [weak self] (shortlistVoteOutcome) in
            
            let shorlistFeedback = self?.viewModel.shortlistFeedback.value
           
            switch shorlistFeedback?.shortlistVoteOutcome {
            case .approved:
                self?.outcomeStatusLabel.text = "Progressing"
                self?.outcomeStatusLabel.backgroundColor = .hcGreen
            case .rejected:
                self?.outcomeStatusLabel.text = "Pulled Out"
                self?.outcomeStatusLabel.backgroundColor = .hcRed
            case .pending:
                self?.outcomeStatusLabel.text = "Decision Pending"
                self?.outcomeStatusLabel.backgroundColor = .darkGray
            default:
                self?.outcomeStatusLabel.text = "Unknown"
                self?.outcomeStatusLabel.backgroundColor = .darkGray
            }
            
        }.disposed(by: disposeBag)
        

        
        setupUI()
    }

    // MARK: - Setup UI
    func setupUI() {
        setupCollectionView()

        
    }

    // MARK: - CollectionView
    func setupCollectionView() {
        flowLayout = (itemsCollectionView.collectionViewLayout as? HCCollectionViewFlowLayout)
        itemsCollectionView.register(UINib(nibName: "ShortlistFeedbackTimelineCellView", bundle: nil), forCellWithReuseIdentifier: "ShortlistFeedbackTimelineCellView")
        itemsCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        viewModel.feedbackReviewers.asObservable().bind(to: itemsCollectionView.rx.items(cellIdentifier: "ShortlistFeedbackTimelineCellView")) {
            (index, item, cell: ShortlistFeedbackTimelineCellView) in
            cell.feedback = item
            cell.setupCell(with: item)
        }.disposed(by: disposeBag)

        viewModel.feedbackReviewers.asObservable().subscribe(onNext: { [weak self] _ in
            self?.itemsCollectionView.reloadData()
            self?.pageControl.numberOfPages = (self?.viewModel.feedbackReviewers.value.count ?? 0)
        }).disposed(by: disposeBag)

        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
    }

    func setupCollectionViewFlowLayout() {
        flowLayout.minimumLineSpacing = Constants.ShortlistFeedbackTimelineCell.space
        flowLayout.itemSize = CGSize(
            width: itemsCollectionView.bounds.size.width - (4 * Constants.ShortlistFeedbackTimelineCell.space),
            height: itemsCollectionView.bounds.size.height
        )

        self.itemsCollectionView.layoutIfNeeded()
        self.flowLayout.invalidateLayout()
        self.itemsCollectionView.reloadData()
    }

}
