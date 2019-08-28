//
//  MapViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 17/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, DatabaseListener, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var sights: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631), latitudinalMeters: 4000, longitudinalMeters: 4000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: false)
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(LocationAnnotation.self))
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sights(_ sender: Any) {
        performSegue(withIdentifier: "sightsSegue", sender: self)
    }
    
    
    func focusOn(annotation: MKAnnotation) {
        mapView.selectAnnotation(annotation, animated: true)
        
        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    
    // MARK: - Database Listener
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        self.sights = sights
        
        mapView.removeAnnotations(mapView.annotations)
        for sight in sights {
            let location = LocationAnnotation(sight: sight)
            mapView.addAnnotation(location)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sightsSegue" {
//            let destination = segue.destination as! SightsTableViewController
//            destination.delegate = self
        }
    }
    
    // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
    /// The map view asks `mapView(_:viewFor:)` for an appropiate annotation view for a specific annotation.
    /// - Tag: CreateAnnotationViews
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? LocationAnnotation {
            annotationView = setupLocationAnnotationView(for: annotation, on: mapView)
        }
        
        return annotationView
    }
    
    // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
    /// Create an annotation view for the Location, and add an image to the callout.
    /// - Tag: CalloutImage
    private func setupLocationAnnotationView(for annotation: LocationAnnotation, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(LocationAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.markerTintColor = UIColor.blue
            
            // Provide an image view to use as the accessory view's detail view.
            let img = loadImageData(filename: annotation.imageFilename!)
            let imgView = UIImageView(image: img)
            // Make image view size 100x100
            imgView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            imgView.contentMode = .scaleAspectFill
            markerAnnotationView.detailCalloutAccessoryView = UIImageView(image: img)
        }
        
        return view
    }
}
