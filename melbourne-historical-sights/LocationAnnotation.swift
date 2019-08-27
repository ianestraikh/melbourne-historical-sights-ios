//
//  LocationAnnotation.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 27/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation  {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(sight: Sight) {
        self.title = sight.name
        self.subtitle = sight.desc
        coordinate = CLLocationCoordinate2D(latitude: sight.latitude, longitude: sight.longitude)
    }

}
