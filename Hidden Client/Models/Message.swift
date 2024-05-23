//
//  Message.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Message: Model {
    
    var id: String?
    var text: String?
    var assetType: String?
    var assetUrl: String?
    var senderType: String?
    var senderName: String?
    var senderPhotoUrl: String?
    var unread: Bool?
    var createdAt: String?
    
    lazy var dateString: String = {
        if let created = createdAt, let date = HCDateFormatter.main.date(from: created) {
            return HCDateFormatter.relative.string(from: date)
        }
        return ""
    }()
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-               map["message__message_id"]
        text <-             map["message__message"]
        assetType <-        map["asset_message__asset_type"]
        assetUrl <-         map["asset_message__cloudinary_url"]
        senderType <-       map["message__sender_type"]
        senderName <-       map["sender__full_name"]
        senderPhotoUrl <-   map["asset_sender_photo__cloudinary_url"]
        unread <-           map["message__unread"]
        createdAt <-        map["message__created_at"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
