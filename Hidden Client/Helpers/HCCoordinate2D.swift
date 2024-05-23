//
//  HCCoordinate2D.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/13.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable { }

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

extension CLLocationCoordinate2D {
    func toString() -> String {
        return "\(self.latitude),\(self.longitude)"
    }
}
