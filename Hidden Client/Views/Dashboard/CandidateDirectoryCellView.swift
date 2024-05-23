//
//  CandidateDirectoryCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 1/17/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RxSwift

class CandidateDirectoryCellView: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var checkedImageView: UIImageView!

    var cellSelected: Bool! = false
    var disposeBag = DisposeBag()

     override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()

        //Do reset here
        self.itemImageView?.image = nil
        self.lblTitle?.text = ""
        self.checkedImageView?.image = nil
    }

    func setupCell(with item: Candidate) {
        self.selectionStyle = .none

        lblTitle.text = item.name
        if item.avatar != nil {
            itemImageView.setImage(with: item.avatar, key: .candidate(item.uid))
        } else {
            itemImageView.image = nil
        }
        hero.modifiers = [.fade]
    }

    func setupCell(with item: HClient) {
        self.selectionStyle = .none

        lblTitle.text = item.fullName
        if item.avatar != nil {
            itemImageView.setImage(with: item.avatar, key: .client(item.uid))
        } else {
            itemImageView.image = nil
        }
        hero.modifiers = [.fade]
    }

    func setupCell(with item: InterviewParticipant) {
        self.selectionStyle = .none

        lblTitle.text = item.clientFullName
        if item.avatar != nil {
            itemImageView.setImage(with: item.avatar, key: .candidate(item.clientId))
        } else {
            itemImageView.image = nil
        }
        hero.modifiers = [.fade]
    }

}
