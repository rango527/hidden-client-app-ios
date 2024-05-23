//
//  MainController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class MainController: UITabBarController {
    
    enum TabBar {
        case processes
        case shortlists
        case jobs
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate.mainVC = self
    }
    
    func getChildVC<T: RootController>() -> T? {
        for vc in viewControllers ?? [] {
            if vc is T {
                return vc as? T
            }
        }
        
        return nil
    }

}
