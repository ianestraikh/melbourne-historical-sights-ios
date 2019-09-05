//
//  Sight+CoreDataClass.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 2/9/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Sight)
public class Sight: NSManagedObject, MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude as Double)
    }
    
    public var title: String? {
        return self.name
    }
    
    public var subtitle: String? {
        return self.desc
    }
    
    public var geoLocation: CLCircularRegion? {
        return CLCircularRegion(center: coordinate, radius: 500, identifier: self.name!)
    }
}
