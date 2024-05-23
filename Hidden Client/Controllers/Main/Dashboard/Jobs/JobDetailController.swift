//
//  JobDetailController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/22.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class JobDetailController: RootController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var bottomLogoImage: UIImageView!
    @IBOutlet weak var lblCompanyProfile: UILabel!
    
    var coverImage: String?
    var jobId: String?
    let viewModel = JobVM()
    var didScrollDown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let id = jobId else { return }
        viewModel.getJobDetail(id)
    }
    
    override func setupAnimations() {
        overlayView.hero.modifiers = [.opacity(1)]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.resizeGradientLayer()
    }
    
    override func setupRx() {
        let gradient = overlayView.addGradientLayer(
            [UIColor.hcMain, UIColor.colorFrom(rgb: 0x4dcf79)],
            start: CGPoint(x:0, y:0), end: CGPoint(x:1, y:1))
        gradient.opacity = 0.75
        
        viewModel.item.subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }).disposed(by: disposeBag)
        
        scrollView.rx.contentOffset.subscribe(onNext: { [weak self] (offset) in
            if -offset.y > UIScreen.main.bounds.height/5.0 {
                self?.didScrollDown = true
            }
        }).disposed(by: disposeBag)
        
        scrollView.rx.didEndDecelerating.subscribe(onNext: { [weak self] _ in
            if self?.didScrollDown == true {
                delay(0.1) {
                    self?.hero.dismissViewController()
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func updateUI() {
        let item = viewModel.item.value
        coverImageView.setImage(with: coverImage)
        logoImageView.setImage(with: item.companyLogo)
        bottomLogoImage.setImage(with: item.companyLogo)
        lblDescription.attributedText = item.getStyledTitle(.colorFrom(rgb: 0x41d07e))
        btnLocation.setTitle(item.cityName ?? "", for: .normal)
        lblCompanyProfile.text = "View the \(item.companyName ?? "") Company Profile"
        
        stackView.removeAllArrangedSubviews()
        setupTiles()
        setupHiddenSaysView()
    }
    
    
    func setupHiddenSaysView() {
        if let item = viewModel.item.value.hiddenSays {
            let hiddenSaysView = HiddenSaysTileView.fromNib() as! HiddenSaysTileView
            hiddenSaysView.setupTile(with: item )
            hiddenSaysView.backgroundColor = .hcMain
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
                tileView.backgroundColor = .hcMain
                stackView.addArrangedSubview(tileView)
            }
        }
    }
    
    @IBAction func onOpenCompanyDetail(_ sender: Any) {
        let vc = CompanyDetailController.fromNib()
        vc.viewModel = CompanyDetailVM()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension JobDetailController: TileViewDelegate {
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
