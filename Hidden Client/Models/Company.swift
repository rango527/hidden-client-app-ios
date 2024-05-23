//
//  Company.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/10.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class Company: Model {
    
    var id: String?
    var name: String?
    var logo: String?
    var coverImage: String?
    var companyStatus: String?
    var sizeId: String?
    var sizeName: String?
    var typeId: String?
    var typeName: String?
    var hiddenSays: String?
    var cities: [CompanyCity]?
    var members: [CompanyPerson]?
    var tiles: [CompanyTile]?
    var createdAt: String?
    var updatedAt: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        id <-               map["company__company_id"]
        name <-             map["company__name"]
        logo <-             map["company_logo_asset__cloudinary_url"]
        coverImage <-       map["company_cover_image_asset__cloudinary_url"]
        companyStatus <-    map["company__status"]
        sizeId <-           map["company_size__company_size_id"]
        sizeName <-         map["company_size__name"]
        typeId <-           map["company_type__company_type_id"]
        typeName <-         map["company_type__name"]
        hiddenSays <-       map["company__hidden_says"]
        cities <-           map["company__cities"]
        members <-          map["company__people"]
        tiles <-            map["company__tiles"]
        createdAt <-        map["company__created_at"]
        updatedAt <-        map["company__last_updated"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
