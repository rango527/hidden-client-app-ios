//
//  AppManager.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/06.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation
import UIKit
import AirshipKit

class AppManager {
    static let shared = AppManager()
    
    // MARK: - Properties
    var token: String?
    var cacheFile: String?
    var user: User?
    var isAdmin: Bool?
    var isAlertReadInProcessSettings: Bool?
    
    // MARK: - Members
    init() {
        readToken()
    }
}

// Token Management
extension AppManager {
    func readToken() {
        if let token = UserDefaults.standard.string(forKey: Constants.Manager.token) {
            self.token = token
            self.isAdmin = UserDefaults.standard.bool(forKey: Constants.Manager.isAdmin)
        }
        
        if let cacheKey = UserDefaults.standard.string(forKey: Constants.Manager.cache) {
            self.cacheFile = cacheKey
        }
    }

    func storeToken(_ token: String?, isAdmin: Bool?) {
        if self.token != token {
            self.token = token
            self.isAdmin = isAdmin

            UserDefaults.standard.setValue(isAdmin, forKey: Constants.Manager.isAdmin)
            UserDefaults.standard.setValue(token, forKey: Constants.Manager.token)
            UserDefaults.standard.synchronize()
        }

        if let uid = user?.uid, cacheFile != "user_\(uid)" {
            cacheFile = "user_\(uid)"
            UserDefaults.standard.setValue(cacheFile, forKey: Constants.Manager.cache)
            UserDefaults.standard.synchronize()
            CacheManager.shared.configure()
        }
    }


    func readValue(key: String) {
        if UserDefaults.standard.string(forKey: key) != nil {
            switch key {
            case Constants.Manager.isAlertReadInProcessSettings:
                self.isAlertReadInProcessSettings = UserDefaults.standard.bool(forKey: key)
            default:
                return
            }
        }
    }

    func storeValue(_ value: Any, key: String) {
        switch key {
        case Constants.Manager.isAlertReadInProcessSettings:
            if isAlertReadInProcessSettings != value as? Bool {
                isAlertReadInProcessSettings = value as? Bool

                UserDefaults.standard.setValue(isAlertReadInProcessSettings, forKey: key)
                UserDefaults.standard.synchronize()
            }
        default:
            return
        }
    }
    
    func updateUser(_ user: User) {
        self.user = user
        let pushId = "client-\(user.uid ?? "")"
        if UAirship.namedUser()?.identifier != pushId {
            UAirship.namedUser()?.identifier = pushId
        }
    }
    
    func login(_ user: User, _ updateUI: Bool? = true) {
        self.user = user
        self.isAdmin = user.isAdmin
        storeToken(user.token, isAdmin: user.isAdmin)
        
        guard updateUI == true else { return }
        if let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController() {
            appDelegate.mainVC = mainVC as? MainController
            appDelegate.mainVC.selectedIndex = 1
            appDelegate.updateWindow(mainVC)
        }
    }
    
    func logout(_ updateUI: Bool? = true) {
        _ = APIManager.getObject(.logout).subscribe()
        user = nil
        storeToken(nil, isAdmin: nil)
        
        UAirship.namedUser()?.identifier = nil
        UAirship.namedUser()?.forceUpdate()
        
        appDelegate.mainVC = nil
        guard updateUI == true else { return }
        appDelegate.updateWindow(SplashController.fromNib())
    }
}
