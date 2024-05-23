//
//  ProcessDetailVC.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/13.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import PKHUD
import ObjectMapper

struct ProcessCardViewData {
    let color: UIColor?
    let title: String?
    let titleColor: UIColor?
    let iconName: String?
    let iconStyle: FontAwesomeStyle?
    let iconColor: UIColor?
    let description: String?
    let buttonTitle: String?
}

protocol ProcessActionDelegate: class {
    func onActionCompleted(message: String)
}

class ProcessDetailVC: RootController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblUnreadMessage: UILabel!
    @IBOutlet weak var unreadMessageView: UIView!
    @IBOutlet weak var progressStackView: UIStackView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var lblProcessTitle: UILabel!
    @IBOutlet weak var lblIconView: UILabel!
    @IBOutlet weak var processImageView: UIImageView!
    @IBOutlet weak var lblProcessDescription: UILabel!
    @IBOutlet weak var btnProcessAction: UIButton!
    @IBOutlet weak var timelineStackView: UIStackView!
    
    var viewModel: ProcessDetailVM!
    var giveAvailability: Bool = false
    
    weak var actionDelegate: ProcessActionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        if giveAvailability {
            btnProcessAction.setTitle(Constants.ProcessStage.ButtonTitle.giveInterviewAvailability, for: .normal)
            btnProcessAction.sendActions(for: .touchUpInside)
        }
    }
    
    override func setupRx() {
        setupUI(process: nil)

        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl!.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] in
            self?.viewModel.getProcessDetail({ result in
                DispatchQueue.main.async { self?.scrollView.refreshControl?.endRefreshing() }
            })
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        viewModel.item.subscribe(onNext: { [weak self] process in
            DispatchQueue.main.async { self?.setupUI(process: process) }
        }).disposed(by: disposeBag)
        
        viewModel.page.subscribe(onNext: { [weak self] (page) in
            guard let process = self?.viewModel?.item.value else { return }
            guard let pages = process.stages?.count, pages > 1 else { return }
            let width = (UIScreen.main.bounds.width - 54) / CGFloat(pages)
            let transform = CGAffineTransform.identity.translatedBy(x: CGFloat(page) * width, y: 0).rotated(by: CGFloat.pi/4.0)
            DispatchQueue.main.async {
                self?.indicatorView.transform = transform
                if let processStage = process.stages?[page],
                    let data = process.stages?[page].getCardViewData(processStage: processStage) {

                    self?.indicatorView.backgroundColor = data.color
                    self?.cardView.backgroundColor = data.color
                    self?.lblProcessTitle.text = data.title
                    self?.lblProcessTitle.textColor = data.titleColor

                    self?.lblIconView.text = data.iconName
                    self?.lblIconView.textColor = data.iconColor
                    self?.lblIconView.font = UIFont.fontAwesome(ofSize: 40.0, style: data.iconStyle!)

                    self?.lblProcessDescription.text = data.description
                    self?.btnProcessAction.isHidden = data.buttonTitle == nil
                    self?.btnProcessAction.setTitle(data.buttonTitle, for: UIControl.State.normal)
                }
            }
        }).disposed(by: disposeBag)
        
        viewModel.timelines.subscribe(onNext: { [weak self] (timelines) in
            self?.timelineStackView.removeAllArrangedSubviews()
            let candidateName = self?.viewModel.item.value.candidateName?.firstName ?? ""
            for timeline in timelines {
                if let view = TimelineView.fromNib() as? TimelineView {
                    self?.timelineStackView.addArrangedSubview(view)
                    view.setupView(with: timeline, candidateName: candidateName)
                    view.delegate = self
                }
            }
        }).disposed(by: disposeBag)
    }

    override func setupAnimations() {
    }
    
    func setupUI(process: Process?) {
        guard let item = process else {
            scrollView.alpha = 0
            return
        }
        
        indicatorView.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4.0)
        
        lblName.text = item.name
        lblJobTitle.text = "For: \(item.jobTitle?.capitalized ?? ""), \(item.jobCity ?? "")"
        avatarImageView.setImage(with: item.avatar, key: .candidate(item.uid))
        lblUnreadMessage.text = item.unread
        unreadMessageView.isHidden = item.unread == nil || item.unread == "0"
        
        progressStackView.removeAllArrangedSubviews()
        for stage in item.stages ?? [] {
            let view = UIView()
            view.cornerRadius = 4
            if stage.stageStatus == Constants.ProcessStage.Status.completed || stage.stageStatus == Constants.ProcessStage.Status.skipped {
                view.backgroundColor = UIColor.hcGreen
            } else if stage.stageStatus == Constants.ProcessStage.Status.current {
                let data = stage.getCardViewData(processStage: stage)
                view.backgroundColor = data.color
            } else {
                view.backgroundColor = UIColor.hcLightGray
            }
            progressStackView.addArrangedSubview(view)
        }
        
        if scrollView.alpha == 0 {
            UIView.animate(withDuration: 0.64) { [weak self] in
                self?.scrollView.alpha = 1
            }
        }
    }
    
    func updatePage(next: Bool) {
        let cnt = viewModel.item.value.stages?.count ?? 0
        if next {
            viewModel.page.accept(max(min(viewModel.page.value + 1, cnt - 1), 0))
        } else {
            viewModel.page.accept(max(min(viewModel.page.value - 1, cnt - 1), 0))
        }
    }
    
    @IBAction func onOpenCandidateDetail(_ sender: Any) {
        let vc = CandidateDetailVC.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        let candidate = Mapper<Candidate>().map(JSON: viewModel.item.value.toJSON())!
        
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.navigationAnimationType = .cover(direction: .up)
        vc.viewModel = CandidateDetailVM(candidate, true)
        vc.isShortlist = false
        vc.view.layoutIfNeeded()
        
        self.present(nav, animated: true)
    }
    
    @IBAction func onMoveProcessStage(_ sender: UIButton) {
        updatePage(next: sender.tag == 2)
    }
    
    @IBAction func onUpdateProcessStage(_ sender: UISwipeGestureRecognizer) {
        updatePage(next: sender.direction == .left)
    }
    
    @IBAction func onOpenMessages(_ sender: Any?) {
        unreadMessageView.isHidden = true
        let vc = MessageController.fromNib()
        vc.viewModel = MessageVM(viewModel.item.value)
        navigationController?.hero.isEnabled = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onProcessActionTapped(_ sender: UIButton) {
        let process = viewModel.item.value
        let btnTitle = (sender.title(for: .normal)?.uppercased() ?? "")

        switch btnTitle {
        case Constants.ProcessStage.ButtonTitle.giveInterviewAvailability:
            let giveAvailability = GiveAvailabilityController.fromNib()
            giveAvailability.viewModel = GiveAvailabilityVM(process)
            giveAvailability.actionDelegate = self
            navigationController?.pushViewController(giveAvailability, animated: true)
        case Constants.ProcessStage.ButtonTitle.giveFeedback:
            if let isAdvancer = process.isInterviewAdvancer, let decisionRequired = process.advanceDecisionNeeded {
                if isAdvancer == false || decisionRequired == false {
                    let feedbackVc = FeedbackVC.fromNib()
                    feedbackVc.viewModel = FeedbackVM(process: process, type: .interview)
                    feedbackVc.actionDelegate = self
                    self.navigationController?.pushViewController(feedbackVc, animated: true)
                } else {
                    let interviewOutcome = InterviewOutcomeViewController.fromNib()
                    interviewOutcome.process = process
                    interviewOutcome.actionDelegate = self
                    navigationController?.pushViewController(interviewOutcome, animated: true)
                }
            }
        case Constants.ProcessStage.ButtonTitle.makeOffer:
            let makeOfferVc = MakeOfferViewController.fromNib()
            makeOfferVc.viewModel = MakeOfferViewModel(process)
            makeOfferVc.actionDelegate = self
            navigationController?.pushViewController(makeOfferVc, animated: true)
        case Constants.ProcessStage.ButtonTitle.giveStartDate:
            let suggestStartDateVc = SuggestStartDateViewController.fromNib()
            suggestStartDateVc.viewModel = SuggestStartDateViewModel(process)
            suggestStartDateVc.actionDelegate = self
            navigationController?.pushViewController(suggestStartDateVc, animated: true)
        case Constants.ProcessStage.ButtonTitle.addInterviewers:
            let availableInterviewsVC = AddInterviewerViewController.fromNib()
            availableInterviewsVC.process = process
            availableInterviewsVC.interviewId = process.interviewId
            availableInterviewsVC.actionDelegate = self
            navigationController?.pushViewController(availableInterviewsVC, animated: true)
        case Constants.ProcessStage.ButtonTitle.joinInterview:
            let availableInterviewsVC = AddInterviewerViewController.fromNib()
            availableInterviewsVC.process = process
            availableInterviewsVC.interviewId = process.interviewId
            availableInterviewsVC.actionDelegate = self
            navigationController?.pushViewController(availableInterviewsVC, animated: true)
        default:
            break
        }
    }
    
    @IBAction func onDismiss(_ sender: UIButton) {
        navigationController?.dismiss(animated: true)        
    }

    @IBAction func onOpenProcessSetting(_ sender: Any) {
        let process = viewModel.item.value
        let vc = ProcessSettingsController.fromNib()
        vc.process = process
        vc.viewModel.getProcessSettings(process.id!, { _ in
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
}

extension ProcessDetailVC: ProcessActionDelegate {
    func onActionCompleted(message: String) {
        viewModel.getProcessDetail()
        viewModel.getProcessTimeline()
        delay(0.3) {
            PKHUD.flashOnTop(with: message)
        }
    }
}

extension ProcessDetailVC: TimelineViewDelegate {
    func onActionTapped(_ sender: UIButton) {
        onProcessActionTapped(sender)
    }
    
    func onOpenMap(with timeline: Timeline) {
        guard let coordinate = timeline.coordinate else { return }
        let mapVc = MapViewController.fromNib()
        mapVc.coordinate = coordinate
        navigationController?.pushViewController(mapVc, animated: true)
    }
    
    func onOpenViewFeedback(with timeline: Timeline) {
        if timeline.type == TimelineType.shortlisted {
            let vc = ShortlistViewFeedbackViewController.fromNib()
            vc.modalPresentationStyle = .fullScreen
            vc.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .cover(direction: .down))
            vc.viewModel = ViewFeedbackViewModel(process: viewModel.item.value, timeline: timeline)
            present(vc, animated: true, completion: nil)
        } else {
            let vc = ViewFeedbackViewController.fromNib()
            vc.modalPresentationStyle = .fullScreen
            vc.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .cover(direction: .down))
            vc.viewModel = ViewFeedbackViewModel(process: viewModel.item.value, timeline: timeline)
            present(vc, animated: true, completion: nil)
        }
    }

    func onOpenViewInterview(with timeline: Timeline) {
        let vc = InterviewDetailViewController.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .cover(direction: .down))
        nav.hero.isEnabled = true
        vc.viewModel = InterviewDetailVM(viewModel.item.value, timeline: timeline)
        vc.viewModel.getInterviewDetail { [weak self] _ in
            self?.present(nav, animated: true)
        }
    }
}

