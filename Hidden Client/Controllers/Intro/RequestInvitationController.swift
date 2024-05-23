//
//  RequestInvitationController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/12.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import PKHUD

final class RequestInvitationController: UIViewController {

    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func onEmaliTeam(_ sender: UIButton) {
        if let url = URL(string: "mailto:\(Constants.Email.support)") {
            if UIApplication.shared.canOpenURL(url) == false {
                HUD.show(.label("Cannot open email app"))
                return
            }
            
            UIApplication.shared.open(url)
        }
    }
}

