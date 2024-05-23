//
//  HCMap.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/08.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation
import MapKit

class HCMap {
    static var cachedSnapshoots: [String: UIImage] = [:]
    
    static func getSnapshot(coordinate: CLLocationCoordinate2D?, radius: Double, size: CGSize, completion: ((UIImage?, CLLocationCoordinate2D?) -> Void)?) {
        guard let coordinate = coordinate else {
            completion?(nil, nil)
            return
        }

        let cacheKey = "\(coordinate.toString())-\(radius)-\(size.width),\(size.height)"
        if cachedSnapshoots.keys.contains(cacheKey) {
            completion?(cachedSnapshoots[cacheKey], coordinate)
            return
        }
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        
        mapSnapshotOptions.region = region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.size = size
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start(with: .global(qos: .background)) { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                DispatchQueue.main.async {
                    completion?(nil, coordinate)
                }
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(mapSnapshotOptions.size, true, 0)
            
            snapshot.image.draw(at: .zero)
            
            let pinImage = #imageLiteral(resourceName: "location-pin-filled")
            var point = snapshot.point(for: coordinate)
            point.x -= pinImage.size.width / 2
            point.y -= pinImage.size.height
            
            pinImage.draw(at: point)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            cachedSnapshoots[cacheKey] = image
            
            DispatchQueue.main.async {
                completion?(image, coordinate)
            }
        }
    }
}
