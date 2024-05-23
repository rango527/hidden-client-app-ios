//
//  ProjectAsset.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class ProjectAsset: Model {
    
    var id: String?
    var type: String?
    var url: String?
    var isMain: Bool?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["project_asset__asset_id"]
        type <-         map["project_asset__asset_type"]
        url <-          map["project_asset__cloudinary_url"]
        isMain <-       map["project_asset__is_main_image"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
