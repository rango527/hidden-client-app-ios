//
//  ShortListsController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import BonMot
import Hero
import RxCocoa

class ShortListsController: RootController {

    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var backgroundOverlayView: UIImageView!
    
    @IBOutlet weak var clientAvatarView: UIImageView!
    @IBOutlet weak var lblWelcome: UILabel!
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var refreshActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnFilter: UIButton!
    
    var isOpeningAnimation = false
    var flowLayout: HCCollectionViewFlowLayout!

    let viewModel = ShortListsVM()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationManager.shared.enableNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (appDelegate.SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: "12.0") ||
            appDelegate.DEVICE_SERIES_MORE_THAN_OR_EQAUL_TO_VERSION_X()) {
            if let candidate = viewModel.items.value.first {
                self.updateUI(with: candidate)
                self.itemsCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .left)
            }
        } else {
            self.updateUI(with: viewModel.focusedItem.value)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionViewFlowLayout()
    }

    // MARK: - Prepare Rx & Animations
    override func setupRx() {
        setupCollectionView()
        setupClientView()
        checkConsentUpdate()
    }
    
    func checkConsentUpdate() {
        viewModel.consents.subscribe(onNext: { [weak self] (consents) in
            guard consents.count > 0 else { return }
            let items = consents
                .filter {$0.newVersion != $0.oldVersion}
                .sorted(by: { (item1, item2) -> Bool in
                    return item1.type == .terms
                })
            guard items.count > 0 else { return }
            
            DispatchQueue.main.async {
                let vc = NewConsentVC.fromNib()
                vc.viewModel = NewConsentVM(items)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    override func setupAnimations() {
        clientAvatarView.hero.modifiers = [.opacity(0), .translate(y: -100)]
        lblWelcome.hero.modifiers = [.opacity(0), .translate(y: -100)]
        itemsCollectionView.panGestureRecognizer.addTarget(self, action: #selector(updateBackgroundAnimation(recognizer:)))
    }
    
    // MARK: - CollectionView
    func setupCollectionView() {
        flowLayout = (itemsCollectionView.collectionViewLayout as? HCCollectionViewFlowLayout)
        itemsCollectionView.register(UINib(nibName: "CardCellView", bundle: nil), forCellWithReuseIdentifier: "CardCellView")
        itemsCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        viewModel.items.asObservable().bind(to: itemsCollectionView.rx.items(cellIdentifier: "CardCellView")) {
            (index, item, cell: CardCellView) in
            cell.setupCell(with: item)
        }.disposed(by: disposeBag)

        itemsCollectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] (indexPath) in
            if let candidate = self?.viewModel.items.value[indexPath.row] {
                self?.viewModel.focusedItem.accept(candidate)

                DispatchQueue.main.async {
                    self?.openDetailVC(candidate)
                }
            }
        }).disposed(by: disposeBag)

        itemsCollectionView.addPullToRefresh(actionHandler: { [weak self] in
            self?.viewModel.getClient(true) {
                DispatchQueue.main.async {
                    self?.itemsCollectionView.pullToRefreshView.stopAnimating()
                    self?.refreshActivityIndicator.stopAnimating()
                }
            }
        }, position: .left)
        itemsCollectionView.pullToRefreshView?.edgeOffset = 2 * Constants.ShortListCard.space
    }
    
    func setupCollectionViewFlowLayout() {
        if flowLayout.minimumLineSpacing != Constants.ShortListCard.space {
            flowLayout.minimumLineSpacing = Constants.ShortListCard.space
            flowLayout.itemSize = CGSize(
                width: view.bounds.size.width - 4 * Constants.ShortListCard.space,
                height: itemsCollectionView.bounds.size.height
            )
            itemsCollectionView.layoutIfNeeded()
            flowLayout.invalidateLayout()
            itemsCollectionView.reloadData()
        }
    }
    
    func updateUI(with item: Candidate) {
        backgroundView.image = UIImage(named: "\(item.avatarColor ?? "blue").png")
    }
    
    // MARK: - Client UI
    func setupClientView() {
        viewModel.firstName.accept(AppManager.shared.user?.firstName ?? "")
        viewModel.title.map { (title) -> NSAttributedString in
            let titleStyle = StringStyle(.font(UIFont.avenirMedium(28)))
            let descStyle = StringStyle(.font(UIFont.avenirBook(15)))
            let descBoldStyle = StringStyle(.font(UIFont.avenirMedium(15)))
            
            let style = StringStyle(
                .color(.white),
                .xmlRules([
                    .style("title", titleStyle),
                    .style("desc", descStyle),
                    .style("bold", descBoldStyle)
                    ]))
            return title.styled(with: style)
        }.bind(to: lblWelcome.rx.attributedText).disposed(by: disposeBag)
        
        viewModel.filter.map {$0.job != nil && $0.location != nil}.asObservable().subscribe(onNext: { [weak self] (isSelected) in
            self?.btnFilter.isSelected = isSelected
            self?.btnFilter.backgroundColor = isSelected ? UIColor.white : UIColor.clear
        }).disposed(by: disposeBag)
        
        viewModel.avatarUrl.asObservable().subscribe(onNext: { [weak self] (url) in
            self?.clientAvatarView.setImage(with: url, key: .client(self?.viewModel.clientId.value))
        }).disposed(by: disposeBag)
        
        viewModel.items.asObservable().subscribe(onNext: { [weak self] (candiates) in
            DispatchQueue.main.async {
                let candidateExists = candiates.count > 0
                let candidate = candiates.first
                self?.backgroundView.image = UIImage(named: candidate?.avatarColor ?? "blue.png")
                self?.updateVisibilityOfEmptyState(hidden: candidateExists)
//                self?.itemsCollectionView.pullToRefreshView.stopAnimating()
            }
        }).disposed(by: disposeBag)
    }
    
    func updateVisibilityOfEmptyState(hidden: Bool) {
        if emptyStateView.superview == nil {
            emptyStateView.frame = itemsCollectionView.frame
            self.view.addSubview(emptyStateView)
        }
        emptyStateView.isHidden = hidden
    }
    
    // MARK: - Actions
    func openDetailVC(_ candidate: Candidate) {
        let vc = CandidateDetailVC.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.navigationAnimationType = .fade
        vc.viewModel = CandidateDetailVM(candidate)
        
        self.present(nav, animated: true)
    }
    
    @IBAction func onForceRefresh(_ sender: UIButton) {
        sender.isEnabled = false
        refreshActivityIndicator.startAnimating()
        viewModel.getClient(true) { [weak self] in
            DispatchQueue.main.async {
                self?.refreshActivityIndicator.stopAnimating()
                sender.isEnabled = true
            }
        }
    }
    
    @IBAction func onOpenFilter(_ sender: Any) {
        let vc = ShortlistFilterVC.fromNib()
        vc.modalPresentationStyle = .overCurrentContext
        vc.viewModel = viewModel
        present(vc, animated: true)
    }
}

// MARK: - Animations
extension ShortListsController {
    @objc func updateBackgroundAnimation(recognizer: UIPanGestureRecognizer) {
        let itemWidth = view.bounds.size.width - 3 * Constants.ShortListCard.space
        let colorLen = viewModel.backgrounds.count
        guard colorLen > 0 else { return }
        
        let translation = recognizer.translation(in: nil)
        let progress = -translation.y / itemsCollectionView.frame.origin.y
        
        switch recognizer.state {
        case .began:
            isOpeningAnimation = 2*abs(translation.x) < -translation.y
            if isOpeningAnimation == true {
                guard let index = flowLayout.currentCenteredPage else { return }
                let candidate = viewModel.items.value[index]
                self.openDetailVC(candidate)
            } else {
                backgroundOverlayView.image = backgroundView.image
                backgroundOverlayView.alpha = 1.0
            }
        case .changed:
            if isOpeningAnimation == true {
                Hero.shared.update(progress)
            } else {
                let velocity = recognizer.velocity(in: itemsCollectionView)
                var page = Int((2 * Constants.ShortListCard.space + itemsCollectionView.contentOffset.x) / itemWidth)
                if velocity.x < 0 {
                    page = page + 1
                }

                backgroundView.image = UIImage(named: viewModel.backgrounds[max(page % colorLen, 0)])
                backgroundOverlayView.alpha = abs(CGFloat(page) - (itemsCollectionView.contentOffset.x + 2 * Constants.ShortListCard.space)/itemWidth)
            }
        case .ended:
            if isOpeningAnimation == true {
                if progress - recognizer.velocity(in: nil).y / itemsCollectionView.frame.origin.y >= 0.5 {
                    Hero.shared.finish()

                    itemsCollectionView.scrollToItem(at: IndexPath(row: flowLayout.currentCenteredPage ?? 0, section: 0), at: .centeredHorizontally, animated: false)
                } else {
                    Hero.shared.cancel()
                }
            } else {
                var page = Int((2 * Constants.ShortListCard.space + flowLayout.targetOffset) / itemWidth)
                page = min(max(0, page), colorLen - 1)

                backgroundView.image = UIImage(named: viewModel.backgrounds[max(page % colorLen, 0)])
                UIView.animate(withDuration: TimeInterval(abs(flowLayout.targetOffset - itemsCollectionView.contentOffset.x)/itemWidth/2.0)) {
                    [weak self] in
                    self?.backgroundOverlayView.alpha = 0
                }

                Hero.shared.cancel()
            }
        default:
            return
        }
    }
}
