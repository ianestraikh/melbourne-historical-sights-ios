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
    var sightToFocus: Sight?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        centerMapOnMelbourne(mapView: mapView)
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(Sight.self))
        mapView.delegate = self
        
        mapView.showsUserLocation = true;
    }
    
    // MARK: - Database Listener
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    
    // MARK: - Database Listener
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func showSightsTable(_ sender: Any) {
        performSegue(withIdentifier: "sightsSegue", sender: self)
    }
    
    // Update annotations every time sight list change
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
        mapView.removeAnnotations(mapView.annotations)
        
        self.sights = sights
        mapView.addAnnotations(sights)
        
        if sightToFocus != nil {
            // An ugly workaround to prevent the marker from hovering above the callout when the annotation selected second time consequently
            // center on different region than one was before
            centerMapOnMelbourne(mapView: mapView)
            
            focusOn(mapView: mapView, annotation: sightToFocus!)
            sightToFocus = nil
        }
    }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sightDetailSegue" {
            let destination = segue.destination as! SightDetailViewController
            destination.sight = sender as? Sight
        } else if segue.identifier == "sightsSegue" {
            let destination = segue.destination as! SightsTableViewController
            destination.mapViewController = self
        }
    }
    
    // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
    /// Called whent he user taps the disclosure button in the bridge callout.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as! Sight? {
            performSegue(withIdentifier: "sightDetailSegue", sender: annotation)
        }
    }
    
    // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if let annotation = annotation as? Sight {
            annotationView = setupAnnotationView(for: annotation, on: mapView)
        }

        return annotationView
    }
    
    // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
    private func setupAnnotationView(for annotation: Sight, on mapView: MKMapView) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(Sight.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.displayPriority = .required
            
            markerAnnotationView.markerTintColor = MARKER_COLORS[Int(annotation.color)]
            markerAnnotationView.glyphImage = UIImage(named: GLYPHIMAGES[Int(annotation.glyphimage)])
            markerAnnotationView.glyphTintColor = UIColor.white
            
            // Provide the annotation view's image.
            let img = loadImageData(filename: annotation.imageFilename!)
            let imgView: UIImageView = {
                let height = markerAnnotationView.frame.height + markerAnnotationView.layoutMargins.top + markerAnnotationView.layoutMargins.bottom
                let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: height, height: height))
                imgView.layer.cornerRadius = CGFloat(5)
                imgView.contentMode = .scaleAspectFill
                imgView.clipsToBounds = true
                imgView.image = img
                
                return imgView
            }()
            
            
            // Provide the left image icon for the annotation.
            markerAnnotationView.leftCalloutAccessoryView = imgView
            
            let rightButton = UIButton(type: .detailDisclosure)
            markerAnnotationView.rightCalloutAccessoryView = rightButton
            
            return markerAnnotationView
        }
        
        return view
    }
}
