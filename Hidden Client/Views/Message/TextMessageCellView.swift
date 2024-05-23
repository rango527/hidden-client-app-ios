//
//  TextMessageCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/17.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class TextMessageCellView: MessageCellView {
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    
    override func setupCell(with item: Message, _ previous: Message? = nil) {
        super.setupCell(with: item, previous)
    
        if isCurrentUser {
            messageContentView.backgroundColor = UIColor.colorFrom(rgb: 0x45c2f7)
            lblSender.text = "You"
            lblSender.textColor = Constants.HiddenColor.darkBlue
            lblContent.text = item.text
            lblContent.textColor = .white
        } else if isColleague {
            messageContentView.backgroundColor = UIColor.colorFrom(rgb: 0xeaeaea)
            lblSender.text = "\(item.senderName ?? "")"
            lblSender.textColor = Constants.HiddenColor.purple
            lblContent.text = item.text
            lblContent.textColor = .black
        } else {
            messageContentView.backgroundColor = UIColor.colorFrom(rgb: 0xeaeaea)
            lblSender.text = "\(item.senderName ?? "") from Hidden"
            lblSender.textColor = Constants.HiddenColor.green
            lblContent.text = item.text
            lblContent.textColor = .black
        }
    }
}
