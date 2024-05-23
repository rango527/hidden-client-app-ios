//
//  DashboardItem.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/12.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

enum DashboardItemType: String {
    case dateTimeLocation = "DateTimeLocationTileList"
    case number = "NumberTileList"
    case photo = "PhotoTileList"
    case none = "None"
}

enum DashboardItemColorScheme: String {
    case light = "light"
    case dark = "dark"
}

enum DashboardItemContentType: String {
    case upcomingInterview  = "UPCOMING_INTERVIEW"
    case metric             = "SIMPLE_METRIC"
    case job                = "JOB"
}

class DashboardItem: Model {
    
    var type: DashboardItemType?
    var title: String?
    var url: String?
    var colorScheme: DashboardItemColorScheme?
    var filter: Dictionary<String, String>?
    var emptyStateDescription: String?
    var emptyStateIcon: String?
    var emptyStateIconUrl: String?
    
    var contentType: DashboardItemContentType?
    var content: [DashboardTile]?

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        type <-             map["type"]
        title <-            map["title"]
        url <-              map["url"]
        colorScheme <-      map["color_scheme"]
        filter <-           map["filter"]
        contentType <-      map["content_type"]
        content <-          map["content"]
        
        emptyStateIcon <-           map["empty_status_icon"]
        emptyStateIconUrl <-        map["empty_status_icon_url"]
        emptyStateDescription <-    map["empty_status"]
    }
    
    required init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
}
