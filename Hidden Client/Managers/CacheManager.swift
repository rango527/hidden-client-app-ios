//
//  CacheManager.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/09.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//


import RealmSwift
import ObjectMapper

/**
 Current Implementation
 ________         _____   |            _____
 Read   1             |       | Update |    |        Update  |    |
 -------------------> | Cache |------->| VM |---|----------> | UI |
 |                    ---------        -----                 ------
 2|                       /|\             /|\     |
 |Call ====-====  Update? |    Update?    |
 |---->|  API  |--------------------------      |
 |     ====-====
 */


class CacheManager {
    
    static let shared = CacheManager()
    
    func configure(){
        let username = (AppManager.shared.cacheFile ?? Constants.Manager.defaultCache).lowercased()
        var config = Realm.Configuration()
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(username).realm")
        print("[Cache DB]", config.fileURL?.absoluteString ?? "")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: - Read/Write Realm
    func readObject<T: Model>(_ r: APIManager) -> T? {
        do {
            let realm = try Realm()
            if let cache = realm.object(ofType: Cache.self, forPrimaryKey: r.cacheUrl) {
                return cache.getObject()
            } else {
                return nil
            }
        } catch {
            print("[CacheManager] read error: \(r.endPoint.path)")
            return nil
        }
    }
    
    func readList<T: Model>(_ r: APIManager) -> [T]? {
        do {
            let realm = try Realm()
            if let cache = realm.object(ofType: Cache.self, forPrimaryKey: r.cacheUrl) {
                return cache.getList()
            } else {
                return nil
            }
        } catch {
            print("[CacheManager] read error: \(r.endPoint.path)")
            return nil
        }
    }
    
    func storeObject<T: Model>(_ object: T, r: APIManager){
        do {
            let realm = try Realm()
            let cache = Cache()
            cache.key = r.cacheUrl
            cache.setJSON(object)
            
            try realm.write {
                realm.add(cache, update: .all)
            }
        } catch {
            print("[CacheManager] write error: \(r.endPoint.path)")
        }
    }
    
    func storeList<T: Model>(_ list: [T], r: APIManager){
        do {
            let realm = try Realm()
            let cache = Cache()
            cache.key = r.cacheUrl
            cache.setJSONList(list)
            
            try realm.write {
                realm.add(cache, update: .all)
                //realm.add(cache, update: true)
            }
        } catch {
            print("[CacheManager] write error: \(r.endPoint.path)")
        }
    }
}
