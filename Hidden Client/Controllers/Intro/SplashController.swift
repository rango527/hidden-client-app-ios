//
//  SplashController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class SplashController: UIViewController {

    var inviteCode: InviteCode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startApp()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func startApp() {
        if inviteCode != nil {
            openInviteAcceptVC()
        } else if AppManager.shared.token != nil {
            openMainVC()
        } else {
            openLoginVC()
        }
    }
    
    func openLoginVC() {
        // - Present mode
        let loginVC = LoginController.inNavigationController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true, completion: nil)

        // - Direct mode
//        let loginVC = LoginController.fromNib()
//        let nav = UINavigationController(rootViewController: loginVC)
//        nav.isNavigationBarHidden = true
//        appDelegate.window?.rootViewController = nav
    }
 
    func openInviteAcceptVC() {
        let inviteAcceptVC = InviteAcceptController.fromNib()
        let nav = UINavigationController(rootViewController: inviteAcceptVC)
        nav.isNavigationBarHidden = true
        
        AppManager.shared.logout(false)
        inviteAcceptVC.inviteCode = inviteCode
        appDelegate.updateWindow(nav)
    }
    
    func openMainVC() {
        if let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController() {
            appDelegate.window?.rootViewController = mainVC
        }
    }
}
