//
//  DocumentMessageCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class DocumentMessageCellView: MessageCellView {
    
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    
    @IBAction func onOpenDocument(_ sender: UIButton) {
        delegate?.onMessageAction(message, nil)
    }
    
    override func setupCell(with item: Message, _ previous: Message? = nil) {
        super.setupCell(with: item, previous)
        
        if isCurrentUser {
            lblSender.text = ""
            lblSender.textColor = Constants.HiddenColor.darkBlue
        } else if isColleague {
            lblSender.text = "\(item.senderName ?? "")"
            lblSender.textColor = Constants.HiddenColor.purple
        } else {
            lblSender.text = "\(item.senderName ?? "") from Hidden"
            lblSender.textColor = Constants.HiddenColor.green
        }
        
        if let assetType = item.assetType, assetType != Constants.Message.AssetType.document {
            lblContent.text = "Shared \(assetType) Document"
        } else {
            lblContent.text = "Shared Document"
        }
    }
}
