//
//  InterviewDetailViewController.swift
//  Hidden Client
//
//  Created by Hideo Den on 3/31/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import PKHUD

class InterviewDetailViewController: RootController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeSegmentCtrl: UISegmentedControl!

    @IBOutlet weak var contentScrView: UIScrollView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var emptyInterviewersView: UIView!
    @IBOutlet weak var interviewersView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addInterviewersButton: UIButton!
    @IBOutlet weak var interviewersTblView: UITableView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeDateView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var emptyTimeLabel: UILabel!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var emptyMapPinImageView: UIImageView!
    @IBOutlet weak var mapAddressLabel: UILabel!

    @IBOutlet weak var secondcontentScrView: UIScrollView!
    @IBOutlet weak var feedbackStackView: UIStackView!
    @IBOutlet weak var emptyFeedbackView: UIView!
    @IBOutlet weak var candidateFeedbackView: UIView!
    @IBOutlet weak var candidateOutcomeStatusLabel: UILabel!
    @IBOutlet weak var candidateFeedbackTranslationLabel: UILabel!
    @IBOutlet weak var ratingScoreView: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var rateIconBtn: UIButton!
    @IBOutlet weak var interviewerFeedbackView: UIView!
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var interviewOutcomeStatusLabel: UILabel!

    let avatarImgViewSize: CGFloat = 20
    let avatarImgViewSpace: CGFloat = 5
    let tapMapViewGestureRecognizier = UITapGestureRecognizer()
    let manageUsersViewModel = ManageUserInProcessRoleVM()
    let dataSource = RxTableViewSectionedReloadDataSource<InterviewerSection>(
        configureCell: { dataSource, table, idxPath, item in
            let cell = table.dequeueReusableCell(withIdentifier: "CandidateDirectoryCellView", for: idxPath) as! CandidateDirectoryCellView
            cell.setupCell(with: item)
            return cell
        },
        canEditRowAtIndexPath: { dataSource, indexPath  in
            return true
        }
    )

    var viewModel: InterviewDetailVM!
    var flowLayout: HCCollectionViewFlowLayout!

    var bInfoLoaded: Bool = false
    var bFeedbackLoaded: Bool = false
    var bFlowLayoutSet: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCollectionViewFlowLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func setupRx() {
        viewModel.item.subscribe(onNext: { [weak self] interview in
            DispatchQueue.main.async {
                HUD.hide()
                guard interview.interviewId != nil else { return }
                self?.titleLabel.text = String(format: "%@ with %@",
                                               interview.description ?? "Interview",
                                               interview.candidateFullName ?? "Unnamed Candidate")
                self?.setupFeedbackView(with: interview)
                self?.setupInfoView(with: interview)
            }
        }).disposed(by: disposeBag)

        setupTableView()
    }

    // MARK: - Setup UI
    func setupUI() {
        let segmentColor = UIColor.init(hex: "F2EFEF")
        typeSegmentCtrl.backgroundColor = segmentColor
        typeSegmentCtrl.layer.borderColor = segmentColor.cgColor
        if #available(iOS 13.0, *) {
            typeSegmentCtrl.selectedSegmentTintColor = UIColor.white
        }
        typeSegmentCtrl.layer.borderWidth = 3
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.hcDarkBlue]
        typeSegmentCtrl.setTitleTextAttributes(titleTextAttributes, for:.normal)
        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor.hcDarkBlue]
        typeSegmentCtrl.setTitleTextAttributes(titleTextAttributes1, for:.selected)
    }

    func showInfoView() {
        secondcontentScrView.isHidden = true
        contentScrView.isHidden = false
    }

    func showFeedbackView() {
        contentScrView.isHidden = true
        secondcontentScrView.isHidden = false
    }

    func setupInfoView(with interview: InterviewTimeline) {
        showInfoView()

        if interview.interviewParticipants == nil || interview.interviewParticipants!.isEmpty {
            if interviewersView != nil {
                interviewersView.removeFromSuperview()
            }
        } else {
            if emptyInterviewersView != nil {
                emptyInterviewersView.removeFromSuperview()
            }

            tblViewHeightConstraint.constant = CGFloat(60 * interview.interviewParticipants!.count)
            interviewersView.layoutIfNeeded()
        }

        // date & time
        if interview.interviewDate != nil {
            emptyTimeLabel.isHidden = true

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            timeLabel.text = dateFormatter.string(from: interview.interviewDate!)
            dateLabel.text = HCDateFormatter.fullDate.string(from: interview.interviewDate!)
        } else {
            emptyTimeLabel.isHidden = false
            timeLabel.text = ""
            dateLabel.text = ""
            emptyTimeLabel.text = "We're just confirming the time and date with everyone"
        }
        //timeDateView.heightAnchor.constraint(equalToConstant: 170.0).isActive = true

        // map
        emptyMapPinImageView.isHidden = interview.coordinate != nil
        if mapImageView.image == nil {
            if let coordinate = interview.coordinate {
                HCMap.getSnapshot(coordinate: coordinate, radius: 1000, size: mapImageView.frame.size) { [weak self] (image, _) in
                    self?.mapImageView.image = image
                }
                self.mapImageView.isUserInteractionEnabled = true
                //self.tapMapViewGestureRecognizier.addTarget(self, action: #selector(onMapTapped))
                self.mapImageView.addGestureRecognizer(tapMapViewGestureRecognizier)
            } else {
                mapImageView.image = nil
            }
        }
        mapAddressLabel.text = interview.location
        //mapView.heightAnchor.constraint(equalToConstant: 260).isActive = true

        DispatchQueue.main.async {
            self.bInfoLoaded = true

            self.infoStackView.leadingAnchor.constraint(equalTo: self.contentScrView.leadingAnchor).isActive = true
            self.infoStackView.trailingAnchor.constraint(equalTo: self.contentScrView.trailingAnchor).isActive = true
            self.infoStackView.topAnchor.constraint(equalTo: self.contentScrView.topAnchor).isActive = true
            self.infoStackView.bottomAnchor.constraint(equalTo: self.contentScrView.bottomAnchor).isActive = true
            // this is important for scrolling
            self.infoStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        }
    }

    func setupFeedbackView(with interview: InterviewTimeline) {
        showFeedbackView()

        // avoid multiple UI registering
        if bFeedbackLoaded {
            return
        }

        if interview.dateAndTime == nil || interview.occursInFuture {
            candidateFeedbackView.removeFromSuperview()
            interviewerFeedbackView.removeFromSuperview()
        } else if interview.occursInPast {
            emptyFeedbackView.removeFromSuperview()
            feedbackStackView.translatesAutoresizingMaskIntoConstraints = false

            //interviewer feedback cards
            setupCollectionViewFlowLayout()
            setupCollectionView()

            // candidate feedback summary
            switch interview.candidateFeedbackDecision {
            case .pending:
                candidateOutcomeStatusLabel.text = "Decision Pending"
                candidateOutcomeStatusLabel.backgroundColor = UIColor(hex: "646161")
            case .progress:
                candidateOutcomeStatusLabel.text = "Progressing"
                candidateOutcomeStatusLabel.backgroundColor = UIColor(hex: "66CC66")
            case .reject:
                candidateOutcomeStatusLabel.text = "Rejected"
                candidateOutcomeStatusLabel.backgroundColor = UIColor(hex: "E74A5F")
            default:
                candidateOutcomeStatusLabel.text = "Decision Pending"
                candidateOutcomeStatusLabel.backgroundColor = UIColor(hex: "646161")
                break
            }
            // candidate feedback card
            let orgCandidateHeight: CGFloat = 250.0
            let feedback = interview.candidateFeedbackTranslation ?? ""
            let score = interview.candidateFeedbackAverage ?? ""
            if feedback.isEmpty, score.isEmpty {
                candidateFeedbackTranslationLabel.text = "Waiting for feedback"
                ratingScoreView.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
                ratingScoreView.isHidden = true
                candidateFeedbackView.heightAnchor.constraint(equalToConstant: orgCandidateHeight - 42.0).isActive = true
            } else {
                candidateFeedbackTranslationLabel.text = "\"\(feedback)\""
                scoreLabel.text = String(format: "%.1f out of 5", Float(score) ?? 0.0)
                ratingScoreView.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
                ratingScoreView.isHidden = false
                candidateFeedbackView.heightAnchor.constraint(equalToConstant: orgCandidateHeight).isActive = true
            }
            
            
            // interviewer feedback summary
            switch interview.interviewerFeedbackDecision {
            case .pending:
                interviewOutcomeStatusLabel.text = "Decision Pending"
                interviewOutcomeStatusLabel.backgroundColor = UIColor(hex: "646161")
            case .progress:
                interviewOutcomeStatusLabel.text = "Progressing"
                interviewOutcomeStatusLabel.backgroundColor = UIColor(hex: "66CC66")
            case .reject:
                interviewOutcomeStatusLabel.text = "Rejected"
                interviewOutcomeStatusLabel.backgroundColor = UIColor(hex: "E74A5F")
            default:
                interviewOutcomeStatusLabel.text = "Decision Pending"
                interviewOutcomeStatusLabel.backgroundColor = UIColor(hex: "646161")
                break
            }

            var interviewHeight: CGFloat = 0.0
            if let inititalFeedback = interview.interviewParticipants?.first {
                interviewHeight = inititalFeedback.heightOfContent() + 161
            }
            self.interviewerFeedbackView.heightAnchor.constraint(equalToConstant: CGFloat(131 + interviewHeight)).isActive = true
        }

        DispatchQueue.main.async {
            self.bFeedbackLoaded = true
            self.feedbackStackView.leadingAnchor.constraint(equalTo: self.secondcontentScrView.leadingAnchor).isActive = true
            self.feedbackStackView.trailingAnchor.constraint(equalTo: self.secondcontentScrView.trailingAnchor).isActive = true
            self.feedbackStackView.topAnchor.constraint(equalTo: self.secondcontentScrView.topAnchor).isActive = true
            self.feedbackStackView.bottomAnchor.constraint(equalTo: self.secondcontentScrView.bottomAnchor).isActive = true
            // this is important for scrolling
            self.feedbackStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        }
    }

    func setupTableView() {
        interviewersTblView.register(UINib(nibName: "CandidateDirectoryCellView", bundle: nil), forCellReuseIdentifier: "CandidateDirectoryCellView")

        interviewersTblView.dataSource = nil
        interviewersTblView.delegate = nil

        viewModel.interviewParticipants.asObservable()
            .bind(to: interviewersTblView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        interviewersTblView.rx.itemDeleted.subscribe(onNext: { [weak self] (indexPath) in
            let processId = self?.viewModel.process.id
            let interviewId = self?.viewModel.item.value.interviewId
            let interview = self?.viewModel.item.value

            if let interviewParticipant = interview!.interviewParticipants?[indexPath.row] {
                self?.manageUsersViewModel.deleteInterviewerInInterview(processId ?? "", interviewId: interviewId ?? "", clientId: Int(interviewParticipant.clientId!) ?? 0, { [weak self] in

                    self?.viewModel.getInterviewDetail()
                })
            }
        }).disposed(by: disposeBag)
    }

    func setupCollectionView() {
        //guard viewModel.item.value.dateAndTime != nil else { return }
        itemsCollectionView.register(UINib(nibName: "InterviewTimelineCellView", bundle: nil), forCellWithReuseIdentifier: "InterviewTimelineCellView")
        itemsCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast

        viewModel.interviewersFeedback.asObservable().bind(to: itemsCollectionView.rx.items(cellIdentifier: "InterviewTimelineCellView")) {
            (index, item, cell: InterviewTimelineCellView) in
            cell.interviewerFeedback = item
            cell.setupCell(with: item, interview: self.viewModel.item.value)
            cell.delegate = self
        }.disposed(by: disposeBag)

        viewModel.interviewersFeedback.asObservable().subscribe(onNext: { [weak self] _ in
            self?.itemsCollectionView.reloadData()
            self?.pageControl.numberOfPages = self?.viewModel.interviewersFeedback.value.count ?? 0
        }).disposed(by: disposeBag)
        

        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
    }

    func setupCollectionViewFlowLayout() {
        guard itemsCollectionView != nil else { return }

        flowLayout = (itemsCollectionView.collectionViewLayout as? HCCollectionViewFlowLayout)
        flowLayout.minimumLineSpacing = Constants.InterviewTimelineCell.space

        let itemWidth = itemsCollectionView.frame.size.width - (4 * Constants.InterviewTimelineCell.space)
        flowLayout.itemSize = CGSize(
            width: itemWidth,
            height: itemsCollectionView.bounds.size.height
        )

        self.itemsCollectionView.layoutIfNeeded()
        self.flowLayout.invalidateLayout()
        self.itemsCollectionView.reloadData()

        bFlowLayoutSet = true
    }

    @IBAction func onInterviewContentTypeSelected(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            showInfoView()
        } else {
            showFeedbackView()
            setupCollectionViewFlowLayout()
        }
    }

    @IBAction func onAddInterviewer(_ sender: UIButton) {
        let interviewId = viewModel.item.value.interviewId
        let availableInterviewsVC = AddInterviewerViewController.fromNib()
        availableInterviewsVC.process = viewModel.process
        availableInterviewsVC.interviewId = interviewId
        availableInterviewsVC.actionDelegate = self
        navigationController?.pushViewController(availableInterviewsVC, animated: true)
    }

    @IBAction func onHelpInfo(_ sender: UIButton) {
        let vc = HelpInfoController.fromNib()
        let shortlistReviewTypeHelp = "The shortlist review type is the workflow or rejecting new candidate submissions. There are 3 types to choose from: Unanimity, Majority or First Choice Rules. If you want to change your workflow or find out more, please get in touch with your Talent Partner"
        vc.helpInfo = shortlistReviewTypeHelp
        self.openController(vc)
    }
}

extension InterviewDetailViewController: InterviewTimelineCellDelegate {
    func nudgeForFeedback(_ feedback: InterviewParticipant) {
        viewModel.nudgeForFeedback(viewModel.process.id ?? "",
                                   feedbackId: feedback.feedbackId ?? "",
                                   clientId: feedback.clientId ?? "")
    }

    func giveFeedback(_ feedback: InterviewParticipant) {
        // Add logic to check if next step decision is needed
        if let isAdvancer = viewModel.item.value.currentClientIsInterviewAdvancer, let decisionRequired = viewModel.item.value.advanceDecisionRequired {
            if isAdvancer == false || decisionRequired == false {
                let feedbackVc = FeedbackVC.fromNib()
                feedbackVc.viewModel = FeedbackVM(process: viewModel.process, interviewers: viewModel?.interviewersFeedback.value, type: .interview)
                feedbackVc.actionDelegate = self
                self.navigationController?.pushViewController(feedbackVc, animated: true)
            } else {
                let interviewOutcome = InterviewOutcomeViewController.fromNib()
                interviewOutcome.process = viewModel.process
                interviewOutcome.actionDelegate = self
                navigationController?.pushViewController(interviewOutcome, animated: true)
            }
        }
    }
}

extension InterviewDetailViewController: ProcessActionDelegate {
    func onActionCompleted(message: String) {
        viewModel.getInterviewDetail()
        delay(0.3) {
            PKHUD.flashOnTop(with: message)
        }
    }
}
