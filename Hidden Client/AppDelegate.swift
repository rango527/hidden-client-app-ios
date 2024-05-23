//
//  AppDelegate.swift
//  Hidden Client
//
//  Created by Guy Tam on 02/07/2018.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import AirshipKit
import Kingfisher
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    weak var mainVC: MainController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        AppManager.shared.readToken()
        startApp()
        enableUAirship()
        integrateSentry()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
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
        
        return false
    }

    func integrateSentry() {
        // Create a Sentry client and start crash handler
        var clientKey: String!
        #if DEVELOPMENT
        clientKey = "https://dfaaf0d6c57e41b0845cd72263fe14e3@sentry.io/1430502"
        #else
        clientKey = "https://0bd82dbcfca24ddc8c5cb553ef4b928e@sentry.io/1430504"
        #endif

        do {
            Client.shared = try Client(dsn: clientKey)
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }
    }

    func enableUAirship() {
        UAirship.setLogLevel(.error)
        
        let config = UAConfig.default()
        config.messageCenterStyleConfig = "UAMessageCenterDefaultStyle"
        UAirship.takeOff(config)
        
        UAirship.push()?.resetBadge()
        UAirship.push()?.isAutobadgeEnabled = true
        
        UAirship.push()?.pushNotificationDelegate = NotificationManager.shared
        UAirship.shared().deepLinkDelegate = DeepLinkManager.shared
    }
    
    func startApp() {
        //ImageCache.default.clearMemoryCache()
        //ImageCache.default.clearDiskCache()
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
        
        if AppManager.shared.token != nil {
            CacheManager.shared.configure()
            if let mainVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController() {
                self.mainVC = mainVC as? MainController
                self.mainVC.selectedIndex = 1
                updateWindow(mainVC)
            }
        } else {
            updateWindow(SplashController.fromNib())
        }
    }
    
    func updateWindow(_ vc: UIViewController) {
        if let window = self.window {
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = vc
            })
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if let uid = AppManager.shared.user?.uid {
            UAirship.namedUser()?.identifier = "client-\(uid)"
        }
    }
}

// MARK: - Convenience Pointers

let appDelegate = UIApplication.shared.delegate as! AppDelegate

// MARK: - Device Information

extension AppDelegate {
    
    func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedSame
    }

    func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedDescending
    }

    func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedAscending
    }

    func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedAscending
    }

    func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
        return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedDescending
    }

    func DEVICE_SERIES_MORE_THAN_OR_EQAUL_TO_VERSION_X() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone {
            //for iphone
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                return false
            case 1334:
                print("iPhone 6/6S/7/8")
                return false
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                return false
            case 2436:
                print("iPhone X, Xs")
                return true
            case 2688:
                print("iPhone Xs Max")
                return true
            case 1792:
                print("iPhone Xr")
                return true
            default:
                print("Default")
                return false
            }
        }else if UIDevice().userInterfaceIdiom == .pad{
            // for ipad
            switch UIScreen.main.nativeBounds.height {
            case 1366:
                print("iPadPro")
                return false
            case 2732:
                print("iPadPro 12")
                return false
            default:
                print("Default")
                return false
            }
        }else{
            // unspecified
            return false
        }
    }

}
