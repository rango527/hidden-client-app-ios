//
//  Cache.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Cache: Object {
    
    // MARK: - Properties
    @objc dynamic var key: String = ""
    @objc dynamic var jsonValue: String? = nil
    
    // Primary key
    override static func primaryKey() -> String? {
        return "key"
    }
    
    override static func indexedProperties() -> [String] {
        return ["key"]
    }
    
    // MARK: - Convert Model to JSON
    func setJSON<T: Mappable>(_ object: T) {
        self.jsonValue = object.toJSONString()
    }
    
    func setJSONList<T: Mappable>(_ object: [T]){
        self.jsonValue = object.toJSONString()
    }
    
    // MARK: - Convert JSON to Model
    func getObject<T: Model>() -> T? {
        var result: T?
        if let json = self.jsonValue {
            result = Mapper<T>().map(JSONString: json)
        }
        
        return result
    }
    
    func getList<T: Model>() -> [T]? {
        var result: [T]?
        if let json = self.jsonValue {
            result = Mapper<T>().mapArray(JSONString: json)
        }
        
        return result
    }
}
