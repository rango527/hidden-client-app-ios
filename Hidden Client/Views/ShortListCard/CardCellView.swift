//
//  CardCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class CardCellView: UICollectionViewCell {
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
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var hiddenSaysContainerView: UIView!
    @IBOutlet weak var brandsContainerView: UIView!
    @IBOutlet weak var projectsContainerView: UIView!
    @IBOutlet weak var skillsContainerView: UIView!
    
    var moreTag: TagView?
    
    var candidate: Candidate!
    var skillRowLimit = 2
    
    func setupCell(with item: Candidate) {
        let length = item.skills?.count ?? 0
        
        self.candidate = item
        hiddenSaysContainerView.isHidden = item.hiddenSays == nil || item.hiddenSays == ""
        skillsContainerView.isHidden = length == 0
        brandsContainerView.isHidden = (candidate?.brands?.count ?? 0) == 0
        projectsContainerView.isHidden = (candidate?.projects?.filter {$0.mainAsset != nil}.count ?? 0) == 0
        
        lblHiddenSays.numberOfLines = 3 +
            (skillsContainerView.isHidden ? 1 : 0) +
            (brandsContainerView.isHidden ? 2 : 0) +
            (projectsContainerView.isHidden ? 2 : 0)
        
        if UIScreen.main.bounds.height < 600 {
            stackView.spacing = 0
            skillRowLimit = 1
            lblHiddenSays.numberOfLines -= 2
        } else if UIScreen.main.bounds.height < 700 {
            lblHiddenSays.numberOfLines -= 1
        }
        
        avatarImageView.setImage(with: item.avatarImage, key: .candidateAvatar(item.uid))
        lblName.text = item.avatarName
        lblLocation.text = item.city
        lblHiddenSays.text = item.hiddenSays
        lblJobTitle.text = [item.jobTitle1, item.jobTitle2, item.jobTitle3].compactMap {$0}.joined(separator: " | ")
        lblJobTitle.textColor = item.color
        
        skillsView.removeAllTags()
        var index = 0
        while index < length {
            let skill = item.skills?[index]
            let tagView = skillsView.addTag(skill?.name ?? "")
            tagView.progressBarColor = item.color
            tagView.ranking = CGFloat(Float(skill?.ranking ?? "0") ?? 0)
            index += 1
            if (skillsView.rows == skillRowLimit) { break }
        }
        
        if index < length {
            //skillsView.removeTag(item.skills?[index].name ?? "")
            moreTag = skillsView.addTag("+\(length-index) more")
            moreTag?.textFont = UIFont.avenirHeavy(13)
            moreTag?.textColor = UIColor.black
            moreTag?.backgroundColor = UIColor.white
            moreTag?.tagBackgroundColor = UIColor.white
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.brandsView.reloadData()
            self?.projectsView.reloadData()
        }
        
        prepareAnimation()
    }
    
    func prepareAnimation() {
        guard let uid = candidate?.uid else { return }
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
}

extension CardCellView: SwipeViewDataSource, SwipeViewDelegate {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        if swipeView == brandsView {
            return candidate?.brands?.count ?? 0
        }
        
        return candidate?.projects?.filter {$0.mainAsset != nil}.count ?? 0
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var itemView: UIImageView
        let view = UIView()
        
        if swipeView == brandsView {
            let brand = candidate.brands?[index]
            
            view.frame              = CGRect(x: 0, y: 0, width: brandsView.bounds.height + 20, height: brandsView.bounds.height)
            itemView                = UIImageView(frame: CGRect(x: 0, y: 0, width: brandsView.bounds.height, height: brandsView.bounds.height))
            itemView.clipsToBounds  = true
            itemView.contentMode    = .scaleAspectFill
            itemView.cornerRadius   = brandsView.bounds.height / 2.0
            itemView.setImage(with: brand?.asset, key: .brand(brand?.assetId))

            view.addSubview(itemView)
            return view
        }
        
        let project = candidate?.projects?.filter {$0.mainAsset != nil}[index]
        let asset = project?.mainAsset
        
        view.frame              = CGRect(x: 0, y: 0, width: 1.2 * projectsView.bounds.height + 5, height: projectsView.bounds.height)
        itemView                = UIImageView(frame: CGRect(x: 0, y: 0, width: 1.2 * projectsView.bounds.height, height: projectsView.bounds.height))
        itemView.clipsToBounds  = true
        itemView.contentMode    = .scaleAspectFill
        itemView.cornerRadius   = 8
        
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
}
