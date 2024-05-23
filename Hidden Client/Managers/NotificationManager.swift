//
//  NotificationManager.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import AirshipKit
import ObjectMapper

class NotificationManager: NSObject, UAPushNotificationDelegate {
    
    static let shared = NotificationManager()
    
    func enableNotification() {
        DispatchQueue.main.async {
            UAirship.push()?.userPushNotificationsEnabled = true
        }
    }
    
    func handleNotification(_ item: Notification) {
        guard let notificationType = item.type else { return }
        guard let mainVC = appDelegate.mainVC else { return }
        
        switch notificationType {
        case .shortlist:
            if let rootVC: ShortListsController = mainVC.getChildVC() {
                guard item.candidateId != nil else { return }
                guard let processId = item.processId else { return }

                _ = APIManager.getObject(.getShortlistCandidate(processId)).subscribe(onNext: { (item: Candidate) in
                    DispatchQueue.main.async {
                        let vc = CandidateDetailVC.fromNib()
                        let nav = UINavigationController(rootViewController: vc)
                        
                        nav.isNavigationBarHidden = true
                        nav.modalPresentationStyle = .fullScreen
                        nav.hero.isEnabled = true
                        nav.hero.navigationAnimationType = .fade
                        vc.viewModel = CandidateDetailVM(item)
                        
                        if mainVC.selectedIndex != 1 {
                            mainVC.selectedIndex = 1
                        }
                        
                        if rootVC.presentedViewController != nil {
                            rootVC.presentedViewController?.dismiss(animated: false, completion: {
                                rootVC.present(nav, animated: true)
                            })
                        } else {
                            rootVC.present(nav, animated: true)
                        }
                    }
                })
                
            }
        case .feedback:
            if let rootVC: ProcessesController = appDelegate.mainVC?.getChildVC() {
                guard let id = item.processId else { return }
                
                _ = APIManager.getObject(.getProcessDetails(id, false)).subscribe(onNext: { (process: Process) in
                    DispatchQueue.main.async {
                        if mainVC.selectedIndex != 2 {
                            mainVC.selectedIndex = 2
                        }
                        if rootVC.presentedViewController != nil {
                            rootVC.presentedViewController?.dismiss(animated: false, completion: {
                                rootVC.openProcessDetail(process)
                            })
                        } else {
                            rootVC.openProcessDetail(process)
                        }
                    }
                })
            }
        case .message:
            if let rootVC: ProcessesController = appDelegate.mainVC?.getChildVC() {
                guard let id = item.processId else { return }
                _ = APIManager.getObject(.getProcessDetails(id, false)).subscribe(onNext: { (process: Process) in
                    DispatchQueue.main.async {
                        rootVC.presentedViewController?.dismiss(animated: false)
                        
                        let nav = UINavigationController()
                        nav.isNavigationBarHidden = true
                        nav.modalPresentationStyle = .fullScreen
                        nav.hero.navigationAnimationType = .fade
                        nav.hero.isEnabled = true
                        
                        let processVC = ProcessDetailVC.fromNib()
                        let messageVC = MessageController.fromNib()
                        processVC.viewModel = ProcessDetailVM(process)
                        messageVC.viewModel = MessageVM(process)
                        
                        if mainVC.selectedIndex != 2 {
                            mainVC.selectedIndex = 2
                        }
                        nav.setViewControllers([processVC, messageVC], animated: false)
                        if rootVC.presentedViewController != nil {
                            rootVC.presentedViewController?.dismiss(animated: false, completion: {
                                rootVC.present(nav, animated: true)
                            })
                        } else {
                            rootVC.present(nav, animated: true)
                        }
                    }
                })
            }
        }
    }
    
    func receivedBackgroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
        // Application received a background notification
        print("The application received a background notification");
        
        // Call the completion handler
        completionHandler(.noData)
    }
    
    func receivedForegroundNotification(_ notificationContent: UANotificationContent, completionHandler: @escaping () -> Swift.Void) {
        // Application received a foreground notification
        print("The application received a foreground notification");
        
        // iOS 10 - let foreground presentations options handle it
        if (ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 10, minorVersion: 0, patchVersion: 0))) {
            completionHandler()
            return
        }
        
        completionHandler()
    }
    
    func receivedNotificationResponse(_ notificationResponse: UANotificationResponse, completionHandler: @escaping () -> Swift.Void) {
        let notificationContent = notificationResponse.notificationContent
        if let extra = notificationContent.notificationInfo["hidden"] as? [String: Any] {
            if let hidden = Mapper<Notification>().map(JSON: extra), let mainVC = appDelegate.mainVC {
                if mainVC.presentedViewController != nil {
                    mainVC.presentedViewController?.dismiss(animated: false, completion: { [weak self] in
                        self?.handleNotification(hidden)
                    })
                } else {
                    handleNotification(hidden)
                }
            }
        }
        
        completionHandler()
    }
    
    @available(iOS 10.0, tvOS 10.0, *)
    func presentationOptions(for notification: UNNotification) -> UNNotificationPresentationOptions {
        return [.alert, .sound]
    }
    
}
