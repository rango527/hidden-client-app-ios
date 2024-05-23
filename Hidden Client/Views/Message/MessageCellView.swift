//
//  MessageCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol MessageCellViewDelegate: class {
    func onMessageAction(_ item: Message, _ action: String?)
}

class MessageCellView: UITableViewCell {
    @IBOutlet weak var contextView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblTimestamp: UILabel!
    @IBOutlet weak var messageContentView: UIView!
    
    var messageTransform: CGAffineTransform!
    var isCurrentUser: Bool!
    var isColleague: Bool!
    var message: Message!
    
    weak var delegate: MessageCellViewDelegate?
    
    func setupCell(with item: Message, _ previous: Message? = nil) {
        self.message = item
        
        // switch over for new sender type
        switch item.senderType {
        case Constants.Message.SenderType.currentUser:
            avatarWidthConstraint.constant = 0
            messageTransform = CGAffineTransform(scaleX: -1, y: 1)
            isCurrentUser = true
            isColleague = false
            
        case Constants.Message.SenderType.colleague:
            avatarWidthConstraint.constant = 42.0
            avatarImageView.setImage(with: item.senderPhotoUrl)
            messageTransform = CGAffineTransform.identity
            isCurrentUser = false
            isColleague = true
            
        default:
            avatarWidthConstraint.constant = 42.0
            avatarImageView.setImage(with: item.senderPhotoUrl)
            messageTransform = CGAffineTransform.identity
            isCurrentUser = false
            isColleague = false
            
        }
        
        lblTimestamp.text = previous?.dateString == item.dateString ? "" : item.dateString
        
        contentView.transform = messageTransform
        lblTimestamp.transform = messageTransform
        messageContentView.transform = messageTransform
    }
}
