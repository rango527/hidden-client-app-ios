//
//  CandidateDetailVC.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/01.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class CandidateDetailVC: RootController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblHiddenCaption: UILabel!
    @IBOutlet weak var lblHiddenSays: UILabel!
    @IBOutlet weak var lblBrandCaption: UILabel!
    @IBOutlet weak var brandsView: SwipeView!
    @IBOutlet weak var lblProjectCaption: UILabel!
    @IBOutlet weak var projectsView: SwipeView!
    @IBOutlet weak var lblSkillsCaption: UILabel!
    @IBOutlet weak var skillsView: TagListView!
    @IBOutlet weak var lblCurrentSalary: UILabel!
    @IBOutlet weak var lblDesiredSalary: UILabel!
    @IBOutlet weak var experienceStackView: UIStackView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnDislike: UIButton!
    
    @IBOutlet weak var hiddenSaysContainerView: UIView!
    @IBOutlet weak var brandsContainerView: UIView!
    @IBOutlet weak var projectsContainerView: UIView!
    @IBOutlet weak var skillsContainerView: UIView!
    @IBOutlet weak var experienceContainerView: UIView!
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var shortListView: UIView!
    @IBOutlet weak var candidateView: UIView!
    @IBOutlet weak var candidateImageView: UIImageView!
    @IBOutlet weak var lblCandidate: UILabel!
    @IBOutlet weak var roundView: UIView!
    
    var viewModel: CandidateDetailVM!
    var isShortlist = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupRx() {
        viewModel.item.asObservable().skip(1).subscribe({ [weak self] _ in
            DispatchQueue.main.async { self?.setupUI() }
        }).disposed(by: disposeBag)
        setupUI()
    }
    
    override func setupAnimations() {
        prepareAnimation()
            
        if isShortlist == true {
            btnLike.hero.modifiers = [.translate(x: 150), .useGlobalCoordinateSpace]
            btnDislike.hero.modifiers = [.translate(x: -150), .useGlobalCoordinateSpace]
            
            candidateView.isHidden = true
            bgView.cornerRadius = 30
            
            delay(1) { [weak self] in
                self?.bgView.cornerRadius = 0
            }
        } else {
            bgView.hero.modifiers = [.translate(y: UIScreen.main.bounds.height - 100), .useGlobalCoordinateSpace]
            
            shortListView.isHidden = true
            btnLike.isHidden = true
            btnDislike.isHidden = true
            roundView.addRoundView()
        }
    }
    
    func prepareAnimation() {
        guard let uid = viewModel.candidateId else { return }
        bgView.hero.id = "background-\(uid)"
        avatarImageView.hero.id = "avatar-\(uid)"
        lblName.hero.id = "name-\(uid)"
        lblLocation.hero.id = "location-\(uid)"
        lblJobTitle.hero.id = "title-\(uid)"
        lblHiddenCaption.hero.id = "hiddenCaption-\(uid)"
        lblHiddenSays.hero.id = "hiddenSays-\(uid)"
        lblBrandCaption.hero.id = "brandCaption-\(uid)"
        brandsView.hero.id = "brands-\(uid)"
        lblProjectCaption.hero.id = "projectCaption-\(uid)"
        projectsView.hero.id = "projects-\(uid)"
        lblSkillsCaption.hero.id = "skillCaption-\(uid)"
        skillsView.hero.id = "skills-\(uid)"
    }
    
    func setupUI() {
        let item = viewModel.item.value
        hiddenSaysContainerView.isHidden = item.hiddenSays == nil || item.hiddenSays == ""
        skillsContainerView.isHidden = (item.skills?.count ?? 0) == 0
        brandsContainerView.isHidden = (item.brands?.count ?? 0) == 0
        projectsContainerView.isHidden = (item.projects?.filter {$0.mainAsset != nil}.count ?? 0) == 0
        experienceContainerView.isHidden = (item.experience?.count ?? 0) == 0
        
        if isShortlist == true {
            backgroundView.image = UIImage(named: "\(item.avatarColor ?? "blue").png")
            if item.avatarImage == nil {
                avatarImageView.setImage(with: item.avatar, key: .candidateAvatar(item.uid))
            } else{
                avatarImageView.setImage(with: item.avatarImage, key: .candidateAvatar(item.uid))
            }
            lblName.text = item.avatarName
        } else {
            backgroundView.image = UIImage(named: "process-gradient.png")
            candidateImageView.setImage(with: item.avatar, key: .candidate(item.uid))
            lblCandidate.text = item.name
        }
        
        lblLocation.text = item.city
        lblHiddenSays.text = item.hiddenSays
        lblJobTitle.text = [item.jobTitle1, item.jobTitle2, item.jobTitle3].compactMap {$0}.joined(separator: " | ")
        lblJobTitle.textColor = item.color
        lblCurrentSalary.text = HCNumberFormatter.ukCurrency(item.currentSalary)
        lblDesiredSalary.text = HCNumberFormatter.ukCurrency(item.desiredSalary)
        
        skillsView.removeAllTags()
        for skill in item.skills ?? [] {
            let tagView = skillsView.addTag(skill.name ?? "")
            tagView.progressBarColor = item.color
            tagView.ranking = CGFloat(Float(skill.ranking ?? "0") ?? 0)
        }
        
        experienceStackView.removeAllArrangedSubviews()
        for experience in item.experience ?? [] {
            if let view = WorkExperienceView.fromNib() as? WorkExperienceView {
                view.setupView(experience)
                experienceStackView.addArrangedSubview(view)
            }
        }
        
        brandsView.dataSource = self
        brandsView.delegate = self
        
        projectsView.dataSource = self
        projectsView.delegate = self
        
        DispatchQueue.main.async { [weak self] in
            self?.brandsView.reloadData()
            self?.projectsView.reloadData()
        }
    }
    
    func openProjectDetail(_ project: Project) {
        let vc = ProjectDetailVC.fromNib()
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel = ProjectDetailVM(project)
        DispatchQueue.main.async { [weak self] in
            self?.present(vc, animated: true)
        }
    }
    
    @IBAction func openFeedbackVC(_ sender: UIButton) {
        let vc = FeedbackVC.fromNib()
        vc.viewModel = FeedbackVM(sender.tag == 1 ? true : false, viewModel.item.value, type: .submission)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CandidateDetailVC: SwipeViewDataSource, SwipeViewDelegate {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        if swipeView == brandsView {
            return viewModel.item.value.brands?.count ?? 0
        }
        return viewModel.item.value.projects?.filter {$0.mainAsset != nil}.count ?? 0
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        var itemView: UIImageView
        let view = UIView()
        
        if swipeView == brandsView {
            let brand = viewModel.item.value.brands?[index]
            
            view.frame              = CGRect(x: 0, y: 0, width: brandsView.bounds.height + 20, height: brandsView.bounds.height)
            itemView                = UIImageView(frame: CGRect(x: 0, y: 0, width: brandsView.bounds.height, height: brandsView.bounds.height))
            itemView.clipsToBounds  = true
            itemView.contentMode    = .scaleAspectFill
            itemView.cornerRadius   = brandsView.bounds.height / 2.0
            itemView.tag            = 1000 + index
            itemView.setImage(with: brand?.asset, key: .brand(brand?.assetId))
            
            view.addSubview(itemView)
            return view
        }
        
        let project = viewModel.item.value.projects?.filter {$0.mainAsset != nil}[index]
        let asset = project?.mainAsset
        
        view.frame              = CGRect(x: 0, y: 0, width: 1.2 * projectsView.bounds.height + 5, height: projectsView.bounds.height)
        itemView                = UIImageView(frame: CGRect(x: 0, y: 0, width: 1.2 * projectsView.bounds.height, height: projectsView.bounds.height))
        itemView.clipsToBounds  = true
        itemView.contentMode    = .scaleAspectFill
        itemView.cornerRadius   = 8
        itemView.tag            = 1000 + index
        itemView.hero.id        = "project-\(project?.id ?? "")"
        
        if asset?.type == Constants.Message.AssetType.video {
            itemView.setImage(with: asset?.url?.thumbnail, key: .projectAsset(asset?.id))
            view.addSubview(itemView)
            
            let playButtonView = UIButton(frame: itemView.bounds)
            playButtonView.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            playButtonView.isUserInteractionEnabled = false
            view.addSubview(playButtonView)
        } else {
            itemView.setImage(with: asset?.url, key: .projectAsset(asset?.id))
            view.addSubview(itemView)
        }
        return view
    }
    
    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        if swipeView == brandsView {
            return CGSize(width: brandsView.bounds.height + 20, height: brandsView.bounds.height)
        }
        return CGSize(width: 1.2 * projectsView.bounds.height + 5, height: projectsView.bounds.height)
    }
    
    func swipeView(_ swipeView: SwipeView!, didSelectItemAt index: Int) {
        if swipeView == projectsView, let project = viewModel.item.value.projects?[index] {
            openProjectDetail(project)
        }
    }
}

