//
//  HCViewController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/12.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import Hero

extension UIViewController {
    static func fromNib( _ animationEnabled: Bool? = true) -> Self {
        let name = String(describing: self)
        let controller = self.init(nibName: name, bundle: nil)
        (controller as UIViewController).hero.isEnabled = animationEnabled ?? true
        return controller
    }
    
    static func inNavigationController( _ animationEnabled: Bool? = true) -> UINavigationController {
        let controller = fromNib(animationEnabled)
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.hero.isEnabled = animationEnabled ?? true
        return navController
    }
}
