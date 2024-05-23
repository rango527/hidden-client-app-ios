//
//  Job.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/21.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper
import BonMot

class Job: Model {
    
    var clientAvatar: String?
    var clientName: String?
    var jobTitle: String?
    var jobStatus: String?
    var salaryFrom: String?
    var salaryTo: String?
    var cityName: String?
    
    var companyId: String?
    var companyName: String?
    var companyLogo: String?
    var coverImage: String?
    var companyStatus: String?
    var sizeId: String?
    var sizeName: String?
    var typeId: String?
    var typeName: String?
    var hiddenSays: String?
    var tiles: [CompanyTile]?
    var createdAt: String?
    var updatedAt: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        clientAvatar <-     map["client_asset__cloudinary_url"]
        clientName <-       map["client__full_name"]
        jobTitle <-         map["job__title"]
        jobStatus <-        map["job__status"]
        salaryFrom <-       map["job__salary_from"]
        salaryTo <-         map["job__salary_to"]
        cityName <-         map["job_city__name"]
        
        companyId <-        map["company__company_id"]
        companyName <-      map["company__name"]
        companyLogo <-      map["company_logo_asset__cloudinary_url"]
        coverImage <-       map["company_cover_image_asset__cloudinary_url"]
        companyStatus <-    map["company__status"]
        sizeId <-           map["company_size__company_size_id"]
        sizeName <-         map["company_size__name"]
        typeId <-           map["company_type__company_type_id"]
        typeName <-         map["company_type__name"]
        hiddenSays <-       map["company__hidden_says"]
        tiles <-            map["job__tiles"]
        createdAt <-        map["job__created_at"]
        updatedAt <-        map["job__last_updated"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
    
    func getStyledTitle(_ color: UIColor? = nil) -> NSAttributedString {
        let text = """
        <title>\(jobTitle?.uppercased() ?? "")</title>
        <at>at</at>
        <name>\(companyName?.uppercased() ?? "")</name>
        <salary>\(HCNumberFormatter.ukCurrency(salaryFrom)) - \(HCNumberFormatter.ukCurrency(salaryTo))</salary>
        """
        let titleStyle = StringStyle(.font(UIFont.avenirBlack(32)))
        let nameStyle = StringStyle(.font(UIFont.avenirHeavy(26)))
        let atStyle = StringStyle(.font(.avenirHeavy(18)))
        let salaryStyle = StringStyle(.font(UIFont.avenirBlack(32)), .color(color ?? .hcMain))
        
        let style = StringStyle(
            .color(.white),
            .xmlRules([
                .style("title", titleStyle),
                .style("at", atStyle),
                .style("name", nameStyle),
                .style("salary", salaryStyle)]))
        
        return text.styled(with: style)
    }

    
    static func stub() -> Job {
        return Job(JSON:
            [
                "client_asset__cloudinary_url": "https://res.cloudinary.com/dioyg7htb/image/upload/v1531845576/hidden/clients/2/photo/5b4e1bc64e478.jpg",
                "client__full_name": "Maggie Smith",
                "job__title": "cheese grater",
                "job__status": "LIVE",
                "job__salary_from": "10000.00",
                "job__salary_to": "20000.00",
                "job_city__name": "London",
                "company__name": "Cheeses Ltd",
                "company__company_id": "400",
                "company_logo_asset__cloudinary_url": "https://res.cloudinary.com/dioyg7htb/image/upload/v1537372246/hidden/companies/1/logo/5ba270565bade.png",
                "company_cover_image_asset__cloudinary_url": "https://res.cloudinary.com/dioyg7htb/image/upload/v1531832625/hidden/companies/1/images/5b4de93084b28.png",
                "company__status": "DRAFT",
                "company_size__company_size_id": "3",
                "company_size__name": "21-50",
                "company_type__company_type_id": "2",
                "company_type__name": "Brand",
                "company__hidden_says": "boo!",
                "job__created_at": "2018-01-02 03:12:12",
                "job__last_updated": "2018-01-02 03:12:12",
                "job__tiles": [
                    [
                        "tile__tile_id": "736",
                        "tile__title": "this is an image",
                        "tile__content": "this is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image textthis is an image text",
                        "tile__type": "TEXT",
                        "tile__sort_order": "0",
                        "tile_asset__cloudinary_url": "https://res.cloudinary.com/dioyg7htb/image/upload/v1531931600/hidden/companies/1/tiles/5b4f6bcfb046e.jpg"
                    ],
                    [
                        "tile__tile_id": "747",
                        "tile__title": "Adorable dog",
                        "tile__content": "Dog lovers know the joy their furry friends bring to them and in honor of this special day \n\nThese excellant intentions were strengthed when he enterd the Father Superior's diniing-room, though, stricttly speakin, it was not a dining-room, for the Father Superior had only two rooms alltogether; they were, however, much larger and more comfortable than Father Zossima's. But tehre was was no great luxury about the furnishng of these rooms eithar. The furniture was of mohogany, covered with leather, in the old-fashionned style of 1820 the floor was not even stained, but evreything was shining with cleanlyness, and there were many chioce flowers in the windows; the most sumptuous thing in the room at the moment was, of course, the beatifuly decorated table. The cloth was clean, the service shone; there were three kinds of well-baked bread, two bottles of wine, two of excellent mead, and a large glass jug of kvas -- both the latter made in the monastery, and famous in the neigborhood. There was no vodka. Rakitin related afterwards that there were five dishes: fish-suop made of sterlets, served with little fish paties; then boiled fish served in a spesial way; then salmon cutlets, ice pudding and compote, and finally, blanc-mange. Rakitin found out about all these good things, for he could not resist peeping into the kitchen, where he already had a footing. He had a footting everywhere, and got informaiton about everything. ",
                        "tile__type": "IMAGE",
                        "tile__sort_order": "1",
                        "tile_asset__cloudinary_url": "https://res.cloudinary.com/dioyg7htb/image/upload/v1537260931/hidden/companies/1/tiles/5ba0bd82530a7.jpg"
                    ],
                    [
                        "tile__tile_id": "746",
                        "tile__title": "Our new member",
                        "tile__content": "Running...",
                        "tile__type": "VIDEO",
                        "tile__sort_order": "2",
                        "tile_asset__cloudinary_url": "https://res.cloudinary.com/dioyg7htb/video/upload/v1536954917/hidden/companies/1/tiles/5b9c122490274.mov"
                    ]
                ]
        ])!
    }
}
