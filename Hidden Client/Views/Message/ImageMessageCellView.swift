//
//  ImageMessageCellView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ImageMessageCellView: MessageCellView {
    @IBOutlet weak var lblSender: UILabel!
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var btnAction: UIButton!
    
    @IBAction func onOpenImage(_ sender: Any) {
        delegate?.onMessageAction(message, nil)
    }
    
    override func setupCell(with item: Message, _ previous: Message? = nil) {
        super.setupCell(with: item, previous)
        
        let key = ImageKey.message(item.id)
        assetImageView.backgroundColor = isCurrentUser ? UIColor.colorFrom(rgb: 0x45c2f7) : UIColor.colorFrom(rgb: 0xeaeaea)
        assetImageView.hero.id = key.name
        if item.assetType == Constants.Message.AssetType.video {
            btnAction.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            assetImageView.setImage(with: item.assetUrl?.thumbnail, key: key)
        } else {
            btnAction.setImage(nil, for: .normal)
            assetImageView.setImage(with: item.assetUrl, key: key)
        }
        
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
    }
}
