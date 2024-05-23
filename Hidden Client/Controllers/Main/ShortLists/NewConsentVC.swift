//
//  NewConsentVC.swift
//  Hidden Talent
//
//  Created by Hideo Den on 2018/11/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit
import PKHUD

class NewConsentVC: RootController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblSwitchDescription: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var webView: WKWebView!
    
    var viewModel: NewConsentVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func setupRx() {
        guard viewModel != nil else { return }
        
        viewModel.title.bind(to: lblTitle.rx.text).disposed(by: disposeBag)
        viewModel.desc.bind(to: lblDescription.rx.text).disposed(by: disposeBag)
        viewModel.switchDescription.bind(to: lblSwitchDescription.rx.text).disposed(by: disposeBag)
        viewModel.buttonTitle.bind(to: btnAccept.rx.title(for: .normal)).disposed(by: disposeBag)
        btnSwitch.rx.isOn.bind(to: viewModel.accepted).disposed(by: disposeBag)
        
        viewModel.accepted.subscribe(onNext: { [weak self] (accepted) in
            DispatchQueue.main.async {
                self?.btnSwitch.isOn = accepted
                self?.btnAccept.isEnabled = accepted || self?.viewModel.buttonTitle.value == "CONTINUE"
                self?.btnAccept.backgroundColor = self?.btnAccept.isEnabled == true ? UIColor.colorFrom(rgb: 0x41D07E) : UIColor.groupTableViewBackground
            }
        }).disposed(by: disposeBag)
        
        viewModel.contentVM.item.subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                guard let content = self?.viewModel.contentVM.getHTMLContent() else { return }
                self?.webView.loadHTMLString(content, baseURL: nil)
            }
        }).disposed(by: disposeBag)
        
        viewModel.page.subscribe(onNext: { [weak self] (page) in
            if let total = self?.viewModel.items?.count, total > 0, total <= page {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: {
                        PKHUD.flashOnTop(with: "Thanks, that’s updated!")
                    })
                }
            }
        }).disposed(by: disposeBag)
    }
    
    @IBAction func onAccept(_ sender: Any) {
        viewModel.updateConsent( btnSwitch.isOn ? "{\"accept_marketing\":true}" : "{\"accept_marketing\":false}" )
    }
}
