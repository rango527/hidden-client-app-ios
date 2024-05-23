//
//  CompanyDetailController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/13.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class CompanyDetailController: RootController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var roundContainerView: UIView!
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var typeNameLabel: UILabel!
    @IBOutlet weak var sizeNameLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!
    
    var viewModel: CompanyDetailVM!
    let tagLineLimit = 2
    var moreTag: TagView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundContainerView.addRoundView()
        scrollView.isHidden = true
    }
    
    override func setupRx() {
        viewModel.item.subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async { self?.setupUI() }
        }).disposed(by: disposeBag)
        
        scrollView.rx.contentOffset.subscribe(onNext: { [weak self] (offset) in
            if offset.y < 0 {
                self?.coverImageHeightConstraint.constant = 280 - offset.y
            }
        }).disposed(by: disposeBag)
    }

    func setupUI() {
        let item = viewModel.item.value
        scrollView.isHidden = item.id == nil
        
        coverImageView.setImage(with: item.coverImage, key: .company("cover_\(item.id ?? "")"))
        brandImageView.setImage(with: item.logo, key: .company(item.id))
        companyNameLabel.text = item.name
        typeNameLabel.text = item.typeName
        sizeNameLabel.text = item.sizeName
        
        tagListView.alignment = .center
        tagListView.paddingX = 8
        tagListView.paddingY = 7
        tagListView.tagBackgroundColor = UIColor.hcMain
        tagListView.textFont = UIFont.avenirRoman(16)
        tagListView.textColor = UIColor.white
        
        initializeTiles()
        setupTagListView(showAll: false)
        setupHiddenSaysView()
        setupTiles()
        setupOurMembersView()
    }
    
    func initializeTiles() {
        var arrangedViews = stackView.arrangedSubviews
        arrangedViews.removeFirst()
        for arrangedView in arrangedViews {
            stackView.removeArrangedSubview(arrangedView)
            arrangedView.removeFromSuperview()
        }
    }
    
    func setupTagListView(showAll: Bool) {
        let items = viewModel.item.value.cities ?? []
        let length = items.count
        var index = 0
        
        tagListView.removeAllTags()
        while index < length {
            let city = items[index]
            let tagView = tagListView.createNewTagView("  \(city.name ?? "")")
            tagView.setImage(#imageLiteral(resourceName: "Pin"), for: .normal)
            tagView.progressBarHeight = 0
            tagListView.addTagView(tagView)
            index += 1
            if (tagListView.rows == tagLineLimit && showAll == false) { break }
        }
        
        if index < length {
            moreTag = tagListView.addTag("+\(length-index) more")
            moreTag?.textColor = UIColor.hcMain
            moreTag?.backgroundColor = UIColor.white
            moreTag?.tagBackgroundColor = UIColor.white
            moreTag?.onTap = { [weak self] _ in
                self?.setupTagListView(showAll: true)
            }
        }
    }
    
    func setupHiddenSaysView() {
        if let item = viewModel.item.value.hiddenSays {
            let hiddenSaysView = HiddenSaysTileView.fromNib() as! HiddenSaysTileView
            hiddenSaysView.setupTile(with: item )
            stackView.addArrangedSubview(hiddenSaysView)
        }
    }
    
    func setupTiles() {
        let items = viewModel.item.value.tiles?.sorted(by: {$0.order ?? "" < $1.order ?? ""}) ?? []
        for item in items {
            var companyTileView: CompanyTileView?
            switch item.type ?? "" {
            case Constants.TileType.text:
                companyTileView = TextTileView.fromNib() as! TextTileView
            case Constants.TileType.image:
                companyTileView = ImageTileView.fromNib() as! ImageTileView
                companyTileView?.delegate = self
            case Constants.TileType.video:
                companyTileView = VideoTileView.fromNib() as! VideoTileView
                companyTileView?.delegate = self
            default:
                print("Missing Tile Type: ", item.type ?? "")
            }
            
            if let tileView = companyTileView {
                tileView.setupTile(with: item)
                stackView.addArrangedSubview(tileView)
            }
        }
    }
    
    func setupOurMembersView() {
        let items = viewModel.item.value.members ?? []
            
        if items.count > 0 {
            let membersView = MembersTileView.fromNib() as! MembersTileView
            membersView.setupTile(with: items.sorted(by: {$0.order ?? "" < $1.order ?? ""}))
            membersView.layoutIfNeeded()
            stackView.addArrangedSubview(membersView)
        }
    }
}

extension CompanyDetailController: TileViewDelegate {
    func openMediaViewer(item: CompanyTile?) {
        let items: [CompanyTile] = (viewModel.item.value.tiles ?? [])
                        .filter {$0.type == Constants.TileType.image || $0.type == Constants.TileType.video}
                        .sorted(by: {$0.order ?? "" < $1.order ?? ""})
        
        var index = 0
        var selectedIndex = 0
        let assets = items.map { (tile) -> MediaViewerImage in
            if tile.id == item?.id {
                selectedIndex = index
            }
            index += 1
            
            if tile.type == Constants.TileType.image {
                return MediaViewerImage(key: .companyTile(tile.id), imageURL: tile.asset, text: tile.assetDescription)
            } else {
                return MediaViewerImage(key: .companyTile(tile.id), imageURL: tile.asset?.thumbnail, text: tile.assetDescription, videoURL: tile.asset)
            }
        }
        
        let mediaViewer = MediaViewerController(images: assets, startIndex: selectedIndex)
        mediaViewer.dynamicBackground = true
        mediaViewer.hero.isEnabled = true
        
        DispatchQueue.main.async { [weak self] in
            self?.present(mediaViewer, animated: true)
        }
    }
}
