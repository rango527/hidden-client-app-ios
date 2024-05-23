//
//  FeedbackVC.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/08.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class FeedbackVC: RootController {


    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var flowLayout: HCCollectionViewFlowLayout!
    var viewModel: FeedbackVM!
    weak var actionDelegate: ProcessActionDelegate?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionViewFlowLayout()
    }
    
    override func setupRx() {
        setupUI()
    }
    
    override func setupAnimations() {
    }

    // MARK: - Setup UI
    func setupUI() {

        lblTitle.text = viewModel.title?.uppercased()
        lblDescription.text = viewModel.titleDescription
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
        setupCollectionView()
    }
    
    // MARK: - CollectionView
    func setupCollectionView() {
        flowLayout = itemsCollectionView.collectionViewLayout as? HCCollectionViewFlowLayout
        itemsCollectionView.register(UINib(nibName: "FeedbackCellView", bundle: nil), forCellWithReuseIdentifier: "FeedbackCellView")
        itemsCollectionView.register(UINib(nibName: "MoreFeedbackCellView", bundle: nil), forCellWithReuseIdentifier: "MoreFeedbackCellView")
        itemsCollectionView.dataSource = self
        itemsCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        viewModel.items.asObservable().subscribe(onNext: { [weak self] _ in
            self?.itemsCollectionView.reloadData()
            self?.pageControl.numberOfPages = (self?.viewModel.items.value.count ?? 0) + 1
        }).disposed(by: disposeBag)
        
        viewModel.page.asObservable().subscribe(onNext: { [weak self] (page) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self?.itemsCollectionView.scrollToItem(at: IndexPath(row: page, section: 0), at: .centeredHorizontally, animated: true)
                self?.pageControl.currentPage = page
            })
        }).disposed(by: disposeBag)
    }
    
    func setupCollectionViewFlowLayout() {
        let scale: CGFloat = UIScreen.main.bounds.width < 370 ? 2.0 : 1.0
        flowLayout.minimumLineSpacing = Constants.FeedbackCell.space / scale
        flowLayout.itemSize = CGSize(
            width: UIScreen.main.bounds.width - 4 * Constants.FeedbackCell.space / scale,
            height: itemsCollectionView.bounds.size.height
        )
        itemsCollectionView.layoutIfNeeded()
        flowLayout.invalidateLayout()
        itemsCollectionView.reloadData()
    }
    
    func showConfirmation(with status: FeedbackOutcome) {
        if let processesVC: ProcessesController = appDelegate.mainVC?.getChildVC() {
            processesVC.viewModel.getProcesses()
        }
        
        let vc = AcceptSubmissionVC.fromNib()
        vc.item = viewModel.candidate
        vc.submissionStatus = status
        itemsCollectionView.hero.modifiers = [.opacity(0)]
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension FeedbackVC: FeedbackCellDelegate {
    func rateQuestion(_ question: FeedbackQuestion, _ rate: Int) {
        viewModel.rateQuestion(question, rate)
    }
    
    func approve(_ comment: String?) {
        if viewModel.type == FeedbackType.submission {
            viewModel.submitVote(with: comment) { [weak self] submissionStatus in
                // completion handler to direct user after submitting shortlist vote
                if let shortListVC: ShortListsController = appDelegate.mainVC?.getChildVC() {
                    shortListVC.viewModel.getClient()
                }
                self?.showConfirmation(with: submissionStatus)
            }
        } else {
            viewModel.submitFeedback(with: comment) { [weak self] in
                // completion handler to direct user after submitting interview feedback
                if let actionDelegate = self?.actionDelegate {
                    if let vc = self?.navigationController?.viewControllers.filter({$0 is ProcessDetailVC}).first {
                        self?.navigationController?.popToViewController(vc, animated: true)
                        actionDelegate.onActionCompleted(message: "Feedback Sent!")
                    } else {
                         self?.navigationController?.dismiss(animated: true)
                    }
                }
            }
        }
    }
}

extension FeedbackVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == viewModel.items.value.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreFeedbackCellView", for: indexPath) as! MoreFeedbackCellView
            cell.setupCell(with: viewModel.acceptance)
            cell.delegate = self
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedbackCellView", for: indexPath) as! FeedbackCellView
        cell.setupCell(with: viewModel.items.value[indexPath.row])
        cell.delegate = self
        
        return cell
    }
}
