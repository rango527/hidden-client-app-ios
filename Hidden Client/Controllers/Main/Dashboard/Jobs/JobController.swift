//
//  JobController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/19.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import BonMot

class JobController: RootController {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnLocation: UIButton!
    
    var coverImage: String?
    var jobId: String?
    let viewModel = JobVM()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let id = jobId else { return }
        viewModel.getJobDetail(id)
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
    }
    
    func updateUI() {
        let item = viewModel.item.value
        coverImageView.setImage(with: coverImage)
        logoImageView.setImage(with: item.companyLogo)
        lblDescription.attributedText = item.getStyledTitle()
        btnLocation.setTitle(item.cityName ?? "", for: .normal)

        delay(1) { [weak self] in
            self?.setupAfterAnimations()
        }
    }
    
    func setupAfterAnimations() {
        lblDescription.hero.modifiers = [.translate(x: UIScreen.main.bounds.width), .opacity(0)]
        btnLocation.hero.modifiers = [.translate(x: UIScreen.main.bounds.width), .opacity(0)]
        overlayView.hero.modifiers = [.opacity(0)]
    }
    
    @IBAction func onOpenJobDetail(_ sender: Any) {
        let vc = JobDetailController.fromNib()
        vc.jobId = jobId
        vc.coverImage = coverImage
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func onOpenJobSetting(_ sender: Any) {
        let vc = JobSettingsController.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.navigationAnimationType = .fade
        nav.hero.isEnabled = true
        vc.jobId = jobId
        present(nav, animated: true)
    }
}
