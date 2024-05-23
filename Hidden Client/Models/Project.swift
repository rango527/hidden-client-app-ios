//
//  Project.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/23.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Project: Model {
    
    var id: String?
    var title: String?
    var brief: String?
    var activity: String?
    var brand: String?
    var brandLogo: String?
    
    var assets: [ProjectAsset]?
    
    lazy var imageAssets: [ProjectAsset] = {
        return assets?.filter({ (asset) -> Bool in
            return asset.type == Constants.Message.AssetType.image
        }) ?? []
    }()
    
    lazy var videoAssets: [ProjectAsset] = {
        return assets?.filter({ (asset) -> Bool in
            return asset.type == Constants.Message.AssetType.video
        }) ?? []
    }()
    
    lazy var mainAsset: ProjectAsset? = {
        return assets?.first(where: { (asset) -> Bool in
            return asset.isMain == true
        })
    }()
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-           map["project__project_id"]
        title <-        map["project__title"]
        brief <-        map["project__brief"]
        activity <-     map["project__activity"]
        brand <-        map["brand__name"]
        brandLogo <-    map["brand_logo__cloudinary_url"]
        
        assets <-       map["candidate__project_assets"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
