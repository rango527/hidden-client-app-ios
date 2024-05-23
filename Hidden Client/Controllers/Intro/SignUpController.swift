//
//  SignUpController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/25.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import BonMot
import PKHUD

class SignUpController: RootController {
    
    @IBOutlet weak var termsSlider: UISwitch!
    @IBOutlet weak var marketingSlider: UISwitch!
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var privacyTextView: UITextView!
    
    let termsUrl = "https://hidden.io/terms"
    let privacyUrl = "https://hidden.io/privacy"
    weak var viewModel: InviteCodeVM?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let terms = "I have read and accept the Hidden <terms>Terms of Service</terms>"
        let privacy = "I want to receive emails from Hidden about updates, news and events\n\nIf you want to read about how we process your personal data please read our <privacy>Privacy Policy</privacy>"
        
        let termsStyle = StringStyle(.color(.colorFrom(rgb: 0x3e7fe1)), .link(URL(string: termsUrl)!))
        let privacyStyle = StringStyle(.color(.colorFrom(rgb: 0x3e7fe1)), .link(URL(string: privacyUrl)!))
        
        let style = StringStyle(
            .color(.white),
            .font(.avenirMedium(16)),
            .xmlRules([
                .style("terms", termsStyle),
                .style("privacy", privacyStyle)]))
        
        termsTextView.attributedText = terms.styled(with: style)
        privacyTextView.attributedText = privacy.styled(with: style)
    }
    
    fileprivate func extractedFunc(_ sender: UIButton) {
        shakeView(sender.superview)
    }
    
    @IBAction func onDone(_ sender: UIButton) {
        if termsSlider.isOn == false {
            extractedFunc(sender)
            PKHUD.flashOnTop(with: "Please accept the Terms", UIColor.hcRed)
        } else {
            viewModel?.marketing = marketingSlider.isOn ? "{\"accept_marketing\":true}" : "{\"accept_marketing\":false}"
            viewModel?.acceptInvite { (user) in
                AppManager.shared.login(user)
            }
        }
    }
}

extension SignUpController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let url = URL.absoluteString
        if url == termsUrl {
            let vc = TermsController.fromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        } else if url == privacyUrl {
            let vc = PrivacyController.fromNib()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        return false
    }
}
