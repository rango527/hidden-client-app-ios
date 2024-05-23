//
//  CompanyPerson.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper
import BonMot

class CompanyPerson: Model {
    var name: String?
    var title: String?
    var content: String?
    var order: String?
    var asset: String?
    
    var styledContent: NSAttributedString {
        let text = "<name>\(name?.stripped.uppercased() ?? "")</name>\n<title>\(title?.stripped.uppercased() ?? "")</title>\n\n<content>\"\(content?.stripped ?? "")\"</content>"
        let nameStyle = StringStyle(.font(UIFont.avenirBlack(20)))
        let titleStyle = StringStyle(.font(UIFont.avenirOblique(18)))
        let contentStyle = StringStyle(.font(UIFont.avenirMediumOblique(20)))
        
        let style = StringStyle(
            .color(.white),
            .xmlRules([
                .style("name", nameStyle),
                .style("title", titleStyle),
                .style("content", contentStyle)]))
        
        return text.styled(with: style)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        name <-         map["company_person__full_name"]
        title <-        map["company_person__job_title"]
        content <-      map["company_person__content"]
        order <-        map["company_person__sort_order"]
        asset <-        map["company_person_asset__cloudinary_url"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
}
