//
//  DashboardController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/07.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DashboardController: RootController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var viewModel = DashboardVM()
    
    override func setupRx() {
        viewModel.items.subscribe(onNext: { [weak self] (items) in
            self?.stackView.removeAllArrangedSubviews()
            items.forEach({ (item) in
                guard item.contentType != nil else { return }

                var itemView: UIView?
                switch item.type ?? .none {
                case .dateTimeLocation:
                    itemView = DashboardDateTimeLocationView.fromNib()
                case .number:
                    itemView = DashboardNumberView.fromNib()
                case .photo:
                    itemView = DashboardPhotoView.fromNib()
                default:
                    break
                }
                if let itemView = itemView {
                    self?.stackView.addArrangedSubview(itemView)
                    (itemView as? DashboardItemViewActions)?.setupView(with: item, delegate: self)
                }
            })
        }).disposed(by: disposeBag)

        // Disable transparency effect
        // scrollView.rx.contentOffset.map {$0.y / 100 + 1.0}.bind(to: scrollView.rx.alpha).disposed(by: disposeBag)

        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl!.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] in
            self?.viewModel.getDashboard(showLoading: true, { result in
                DispatchQueue.main.async { self?.scrollView.refreshControl?.endRefreshing() }
                if result {} else {}
            })
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    @IBAction func onOpenSettings(_ sender: Any) {
        let vc = SettingsController.fromNib()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension DashboardController: DashboardItemViewDelegate {
    func onHandleAction(item: DashboardItem, info: DashboardTile? = nil) {
        
        guard let contentType = item.contentType else { return }
        
        switch contentType {
        case .upcomingInterview:
            let vc = ProcessDetailVC.fromNib()
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            nav.hero.navigationAnimationType = .fade
            nav.hero.isEnabled = true
            let process = Process()
            process.id = info?.extra?["process_id"] as? String
            vc.viewModel = ProcessDetailVM(process)
            
            present(nav, animated: true)
        case .job:
            let vc = JobController.fromNib()
            let nav = UINavigationController(rootViewController: vc)
            nav.isNavigationBarHidden = true
            nav.modalPresentationStyle = .fullScreen
            nav.hero.navigationAnimationType = .fade
            nav.hero.isEnabled = true
            vc.jobId = info?.extra?["job_id"] as? String
            vc.coverImage = info?.photo
            
            present(nav, animated: true)
        default:
            return
        }
        
    }
}
