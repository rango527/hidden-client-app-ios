//
//  CompanyTile.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//


import ObjectMapper

class CompanyTile: Model {
    
    var id: String?
    var title: String?
    var content: String?
    var type: String?
    var order: String?
    var asset: String?
    
    var assetDescription: String {
        if let _title = title, let _content = content {
            return "\(_title)\n\n\(_content)"
        } else if let _title = title {
            return "\(_title)"
        } else if let _content = content {
            return "\(_content)"
        }
        
        return ""
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["tile__tile_id"]
        title <-        map["tile__title"]
        content <-      map["tile__content"]
        type <-         map["tile__type"]
        order <-        map["tile__sort_order"]
        asset <-        map["tile_asset__cloudinary_url"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
