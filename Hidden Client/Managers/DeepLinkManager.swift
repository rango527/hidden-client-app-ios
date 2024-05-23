//
//  DeepLinkManager.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import ObjectMapper
import AirshipKit

class DeepLinkManager: NSObject {
    static let shared = DeepLinkManager()
    
    func handleDeepLink(_ action: String?, _ object: [String: String]?) {
        guard let _action = action, let _object = object else { return }
        
        switch _action {
        case "invite":
            if let invitation = Mapper<InviteCode>().map(JSON: _object) {
                openInviteVC(invitation)
            }
        case "forgotten-password":
            if let token = Mapper<InviteCode>().map(JSON: _object) {
                openForgottenPassword(token)
            }
        default:
            return
        }
    }
    
    func openInviteVC(_ invitation: InviteCode) {
        let inviteAcceptVC = InviteAcceptController.fromNib()
        let nav = UINavigationController(rootViewController: inviteAcceptVC)
        nav.isNavigationBarHidden = true
        
        AppManager.shared.logout(false)
        inviteAcceptVC.inviteCode = invitation
        appDelegate.updateWindow(nav)
    }
    
    func openForgottenPassword(_ token: InviteCode) {
        let setPasswordVC = SetPasswordController.fromNib()
        AppManager.shared.logout(false)
        setPasswordVC.inviteCode = token
        appDelegate.updateWindow(setPasswordVC)
    }
}

extension DeepLinkManager: UADeepLinkDelegate {
    func receivedDeepLink(_ url: URL, completionHandler: @escaping () -> ()) {
        
        var value = [String: String]()
        if let query = url.query {
            for params in query.components(separatedBy: "&") {
                let pairs = params.components(separatedBy: "=")
                if pairs.count > 0 {
                    value[pairs[0]] = pairs[1]
                }
            }
        }
        
        if let host = url.host {
            DeepLinkManager.shared.handleDeepLink(host, value)
        }
        
        completionHandler()
    }
}
