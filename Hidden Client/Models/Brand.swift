//
//  Brand.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Brand: Model {
    
    var id: String?
    var name: String?
    var assetId: String?
    var asset: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["brand__brand_id"]
        name <-         map["brand__name"]
        assetId <-      map["asset__asset_id"]
        asset <-        map["asset__cloudinary_url"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
