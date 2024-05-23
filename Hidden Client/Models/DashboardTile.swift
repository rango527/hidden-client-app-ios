//
//  DashboardTile.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/12.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper
import CoreLocation

class DashboardTile: Model {
    
    /* DateTimeLocationTile */
    var photo: String?
    var label1: String?
    var label2: String?
    var label3: String?
    var latLng: [String]?
    var mapOverlay: Dictionary<String, String>?
    var processId: String?
    
    /* NumberTile */
    var title: String?
    var value: String?
    
    /* PhotoTile */
    //  photo: String?
    var tag: String?
    var tagColor: String?
    //  title: String?
    var subtitle: String?
    
    var extra: [String: Any]?
    
    override func mapping(map: Map) {
        photo <-            map["photo"]
        label1 <-           map["label_1"]
        label2 <-           map["label_2"]
        label3 <-           map["label_3"]
        latLng <-           map["lat_lng"]
        mapOverlay <-       map["map_overlay"]
        processId <-        map["extra.process_id"]
        
        value <-            map["value"]
        
        tag <-              map["tag"]
        tagColor <-         map["tag_colour"]
        title <-            map["title"]
        subtitle <-         map["subtitle"]
        
        extra <-            map["extra"]
    }
    
    required init(){
        super.init()
    }
    
    required init?(map: Map){
        super.init(map: map)
    }
    
    lazy var coordinate: CLLocationCoordinate2D? = {
        guard let latlng = latLng?.map({Double($0) ?? 0}) else { return nil }
        return CLLocationCoordinate2D(latitude: latlng[0], longitude: latlng[1])
    }()
    
    lazy var tagColorValue: UIColor? = {
        guard let tagColor = tagColor, let rgb = Int(tagColor, radix: 16) else { return nil }
        return UIColor.colorFrom(rgb: rgb)
    }()
    
    lazy var mapOverlayValue: (top: String, bottom: String)? = {
        if let dateString = mapOverlay?["date_and_time"], let date = HCDateFormatter.main.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let timeValue = dateFormatter.string(from: date)
            let dateValue = HCDateFormatter.relativeDate.string(from: date)
            return (top: timeValue, bottom: dateValue)
        }
        else if let topValue = mapOverlay?["top"], let bottomValue = mapOverlay?["bottom"] {
            return (top: topValue, bottom: bottomValue)
        }
        return nil
    }()
}
