//
//  SettingsMenu.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/07.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import ObjectMapper

class SettingsMenu {
    var title: String?
    var imageKey: ImageKey?
    var imageUrl: String?
    
    convenience init(_ title: String, key: ImageKey? = nil, url: String? = nil) {
        self.init()
        self.title = title
        self.imageKey = key
        self.imageUrl = url
    }
}
