//
//  ProjectDetailVC.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/06.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import Kingfisher

class ProjectDetailVC: RootController {

    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var btnBrandImage: UIButton!
    @IBOutlet weak var lblProjectTitle: UILabel!
    @IBOutlet weak var lblCompany: UILabel!
    @IBOutlet weak var lblBrief: UILabel!
    @IBOutlet weak var lblAction: UILabel!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var videoContainerView: UIView!
    @IBOutlet weak var imagesView: SwipeView!
    @IBOutlet weak var videosView: SwipeView!
    
    var viewModel: ProjectDetailVM!
    
    lazy var assetItems: [MediaViewerImage]! = {
        let assets = viewModel.item.value.imageAssets + viewModel.item.value.videoAssets
        let items = assets.map { (asset) -> MediaViewerImage in
            if asset.type == Constants.Message.AssetType.image {
                return MediaViewerImage(key: .projectAsset(asset.id), imageURL: asset.url)
            } else {
                return MediaViewerImage(key: .projectAsset(asset.id), imageURL: asset.url?.thumbnail, videoURL: asset.url)
            }
        }
        return items
    }()

    override func setupRx() {
        viewModel.item.asObservable().skip(1).subscribe({ [weak self] _ in
            DispatchQueue.main.async { self?.setupUI() }
        }).disposed(by: disposeBag)
        setupUI()
    }
    
    override func setupAnimations() {
        guard let id = viewModel.projectId else { return }
        brandImageView.hero.id = "project-\(id)"
    }
    
    func setupUI() {
        let project = viewModel.item.value
        let asset = project.mainAsset
        if asset?.type == Constants.Message.AssetType.video {
            brandImageView.setImage(with: asset?.url?.thumbnail, key: .projectAsset(asset?.id))
            btnBrandImage.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        } else {
            brandImageView.setImage(with: asset?.url, key: .projectAsset(asset?.id))
        }
        
        lblProjectTitle.text = project.title
        lblCompany.text = project.brand
        lblBrief.text = project.brief
        lblAction.text = project.activity
        
        imageContainerView.isHidden = project.imageAssets.count == 0
        videoContainerView.isHidden = project.videoAssets.count == 0
        
        imagesView.dataSource = self
        imagesView.delegate = self
        imagesView.reloadData()
        
        videosView.dataSource = self
        videosView.delegate = self
        videosView.reloadData()
    }
    
    func openMediaViewer(index: Int) {
        let mediaViewer = MediaViewerController(images: assetItems, startIndex: index)
        mediaViewer.dynamicBackground = true
        mediaViewer.hero.isEnabled = true
        
        DispatchQueue.main.async { [weak self] in
            self?.present(mediaViewer, animated: true)
        }
    }
    
    @IBAction func onOpenMediaViewer(_ sender: Any) {
        let assets = viewModel.item.value.imageAssets + viewModel.item.value.videoAssets
        if let index = assets.firstIndex(where: {$0.isMain == true}) {
            openMediaViewer(index: index)
        }
    }
}


extension ProjectDetailVC: SwipeViewDataSource, SwipeViewDelegate {
    func numberOfItems(in swipeView: SwipeView!) -> Int {
        if swipeView == imagesView {
            return viewModel.item.value.imageAssets.count
        }
        return viewModel.item.value.videoAssets.count
    }
    
    func swipeView(_ swipeView: SwipeView!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        var itemView: UIImageView!
        let view = UIView()
        
        
        let asset = swipeView == videosView ? viewModel.item.value.videoAssets[index] : viewModel.item.value.imageAssets[index]
        
        view.frame              = CGRect(x: 0, y: 0, width: 1.2 * imagesView.bounds.height + 5, height: imagesView.bounds.height)
        itemView                = UIImageView(frame: CGRect(x: 0, y: 0, width: 1.2 * imagesView.bounds.height, height: imagesView.bounds.height))
        itemView.clipsToBounds  = true
        itemView.contentMode    = .scaleAspectFill
        itemView.cornerRadius   = 8
        itemView.tag            = 1000 + index

        if swipeView == videosView {
            itemView.setImage(with: asset.url?.thumbnail, key: .projectAsset(asset.id))
            view.addSubview(itemView)
            
            let playButtonView = UIButton(frame: itemView.bounds)
            playButtonView.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            playButtonView.isUserInteractionEnabled = false
            view.addSubview(playButtonView)
        } else {
            itemView.setImage(with: asset.url, key: .projectAsset(asset.id))
            view.addSubview(itemView)
        }
        
        return view
    }
    
    func swipeViewItemSize(_ swipeView: SwipeView!) -> CGSize {
        return CGSize(width: 1.2 * imagesView.bounds.height + 5, height: imagesView.bounds.height)
    }
    
    func swipeView(_ swipeView: SwipeView!, didSelectItemAt index: Int) {
        let selectedIndex = index + (swipeView == videosView ? viewModel.item.value.imageAssets.count : 0)
        openMediaViewer(index: selectedIndex)
    }
}
