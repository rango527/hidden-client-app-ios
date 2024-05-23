//
//  RootController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift
import Spring

@objc protocol Presenter {
    @objc optional func updateUI()
}

class RootController: UIViewController, Presenter {
    let disposeBag = DisposeBag()
    
    func setupAnimations() {}
    func setupRx() {}
    func sendRequest() {}

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimations()
        setupRx()
    }
}

// MARK: - Auto Keyboard
extension RootController: UITextFieldDelegate {
    fileprivate func extractedFunc() {
        sendRequest()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if IQKeyboardManager.shared.canGoNext {
            IQKeyboardManager.shared.goNext()
        } else {
            extractedFunc()
        }
        
        return false
    }
}

// MARK: - Animations
extension RootController {
    func shakeView(_ view: UIView?) {
        if let springView = view as? SpringView {
            springView.animation = "shake"
            springView.duration = 0.1
            springView.repeatCount = 3
            springView.animate()
        }
    }
    
    func openController(_ vc: UIViewController) {
        vc.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .cover(direction: .down))
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async { [weak self] in
            self?.present(vc, animated: true)
        }
    }
}

