//
//  AcceptSubmissionVC.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class AcceptSubmissionVC: RootController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblCongratulation: UILabel!
    @IBOutlet weak var btnShortlist: UIButton!
    @IBOutlet weak var btnProcesses: UIButton!
    
    var item: Candidate!
    var submissionStatus: FeedbackOutcome = FeedbackOutcome.pending
    
    override func setupRx() {
        if submissionStatus == .accepted {
            avatarImageView.setImage(with: item.avatarImage, key: .candidateAvatar(item.uid))
            profileImageView.setImage(with: item.avatar, key: .candidate(item.uid))
            lblName.text = item.avatarName
            lblFullName.text = item.name
            lblJobTitle.text = "For: \(item.jobTitle ?? ""), \(item.city ?? "")"
            lblCongratulation.text = "Congratulations, \(item.name?.components(separatedBy: " ").first ?? item.name ?? "") has been progressed to First Stage Interview!"
        } else {
            setupViewWithoutAnimation()
        }
    }
    
    func setupViewWithoutAnimation() {
         if submissionStatus == .pending {
            lblCongratulation.text = "Thanks for your feedback and vote. Once your colleagues have voted, you'll be notified of the outcome!"
            lblName.text = item.avatarName
            avatarImageView.setImage(with: item.avatarImage)
            
            lblFullName.isHidden = true
            profileImageView.isHidden = true
            lblJobTitle.isHidden = true
            btnProcesses.isHidden = true
            headerView.isHidden = true
         } else if submissionStatus == .rejected {
            lblCongratulation.text = "The votes are in and \(item.avatarName ?? "the candidate") has been rejected. We'll let them know."
            lblName.text = item.avatarName
            avatarImageView.setImage(with: item.avatarImage)
            
            lblFullName.isHidden = true
            profileImageView.isHidden = true
            lblJobTitle.isHidden = true
            btnProcesses.isHidden = true
            headerView.isHidden = true
        }
       
    }
    
    override func setupAnimations() {
        if submissionStatus == .accepted {
            let width = UIScreen.main.bounds.width
            let rect =  CGRect(origin: CGPoint.zero, size: CGSize(width: width, height: 0))
            //headerView.hero.modifiers = [.delay(2), .position(CGPoint(x: width/2.0, y: 0)), .size(CGSize(width: width, height: 0))]
            headerView.hero.modifiers = [.delay(2), .position(CGPoint(x: width/2.0, y: 0)), .contentsRect(rect)]
            headerView.hero.modifiers = [.delay(2), .position(CGPoint(x: width/2.0, y: 0)), .size(CGSize(width: width, height: 0))]
            lblCongratulation.hero.modifiers = [.delay(2), .opacity(0.0)]
            btnShortlist.hero.modifiers = [.delay(2), .translate(x: width)]
            btnProcesses.hero.modifiers = [.delay(2), .translate(x: width)]
        }
    }
    
    @IBAction func onBackToShortlists(_ sender: Any) {
        self.view.hero.isEnabledForSubviews = false
        self.navigationController?.dismiss(animated: true)
    }
    
    @IBAction func onGoToProcesses(_ sender: Any) {
        let vc = ProcessDetailVC.fromNib()
        let process = Process()
        process.id = item.processId
        vc.viewModel = ProcessDetailVM(process)
       // vc.giveAvailability = true
        navigationController?.pushViewController(vc, animated: false)
        appDelegate.mainVC.selectedIndex = 2
    }
}
