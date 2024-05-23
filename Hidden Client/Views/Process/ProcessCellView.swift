//
//  ProcessCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/02.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import BonMot

class ProcessCellView: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarContainerView: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUnreadMessage: UILabel!
    @IBOutlet weak var unreadMessageContainerView: UIView!
    @IBOutlet weak var processStackView: UIStackView!
    
    func setupCell(with item: Process) {
        let text = "<title>\(item.name ?? "")</title>\n<desc>For: \(item.jobTitle?.capitalized ?? ""), \(item.jobCity ?? "")</desc>"
        let titleStyle = StringStyle(.font(UIFont.avenirHeavy(19)))
        let descStyle = StringStyle(.font(UIFont.avenirBook(16)))

        let style = StringStyle(
            .color(.black),
            .xmlRules([
                .style("title", titleStyle),
                .style("desc", descStyle),
            ]))
        lblTitle.attributedText = text.styled(with: style)
        avatarImageView.setImage(with: item.avatar, key: .candidate(item.uid))
        lblUnreadMessage.text = item.unread
        
        if item.unread == nil || item.unread == "0" {
            unreadMessageContainerView.isHidden = true
            avatarContainerView.layer.borderWidth = 0
        } else {
            unreadMessageContainerView.isHidden = false
            avatarContainerView.layer.borderWidth = 2
            avatarContainerView.layer.borderColor = UIColor.colorFrom(rgb: 0xCF2E2B).cgColor
        }
        
        processStackView.removeAllArrangedSubviews()
        for stage in item.stages ?? [] {
            let view = UIView()
            view.cornerRadius = 4
            if stage.stageStatus == Constants.ProcessStage.Status.completed || stage.stageStatus == Constants.ProcessStage.Status.skipped {
                view.backgroundColor = UIColor.hcGreen
            } else if stage.stageStatus == Constants.ProcessStage.Status.current {
                let data = stage.getCardViewData(processStage: stage)
                view.backgroundColor = data.color
            } else {
                view.backgroundColor = UIColor.hcLightGray
            }
            processStackView.addArrangedSubview(view)
        }
    }
}
