//
//  Util.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 19/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//
import UIKit
import MapKit

func loadImageData(filename: String) -> UIImage? {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    let url = NSURL(fileURLWithPath: path)
    var image: UIImage?
    if let pathComponent = url.appendingPathComponent(filename) {
        let filePath = pathComponent.path
        let fileManager = FileManager.default
        let fileData = fileManager.contents(atPath: filePath)
        image = UIImage(data: fileData!)
    }
    
    return image
}

func centerMapOnMelbourne(mapView: MKMapView) {
    let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631), latitudinalMeters: 4000, longitudinalMeters: 4000)
    mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: false)
}

func focusOn(mapView: MKMapView, annotation: MKAnnotation) {
    for annotaion in mapView.selectedAnnotations {
        mapView.deselectAnnotation(annotaion, animated: false)
    }
    
    let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
    mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    
    mapView.selectAnnotation(annotation, animated: true)
}
