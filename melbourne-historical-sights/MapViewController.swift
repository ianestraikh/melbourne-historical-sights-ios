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
            // An ugly workaround to prevent the marker from hovering above the callout when the annotation selected second time consequentally
            // move region to different one than it was before
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
        
        // This illustrates how to detect which annotation type was tapped on for its callout.
        if let annotation = view.annotation as! Sight? {
            performSegue(withIdentifier: "sightDetailSegue", sender: annotation)
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
        
        if let annotation = annotation as? Sight {
            annotationView = setupAnnotationView2(for: annotation, on: mapView)
        }
        
        return annotationView
    }
    
    // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
    /// Create an annotation view for and add an image and desc to the callout.
    private func setupAnnotationView(for annotation: Sight, on mapView: MKMapView) -> MKAnnotationView {
        let identifier = NSStringFromClass(Sight.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.markerTintColor = UIColor.blue
            markerAnnotationView.displayPriority = .required
            
            let img = loadImageData(filename: annotation.imageFilename!)
            let imgView: UIImageView = {
                let imgView = UIImageView(image: img)
                let widthConstraint = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: CGFloat(1), constant: CGFloat(100))
                let heightConstraint = NSLayoutConstraint(item: imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: CGFloat(1), constant: CGFloat(100))
                imgView.addConstraints([widthConstraint, heightConstraint])
                imgView.contentMode = .scaleAspectFill
                
                return imgView
            }()
            
            let descLabel: UILabel = {
                let label = UILabel(frame: .zero)
                label.text = annotation.desc
                label.numberOfLines = 5
                label.font = UIFont.preferredFont(forTextStyle: .caption1)
                let widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: CGFloat(1), constant: CGFloat(200))
                label.addConstraint(widthConstraint)
                
                return label
            }()
            
            let stackView: UIStackView = {
                let stackView = UIStackView(arrangedSubviews: [imgView, descLabel])
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.axis = .horizontal
                stackView.alignment = .top
                stackView.spacing = CGFloat(10)
                
                return stackView
            }()
            
            markerAnnotationView.detailCalloutAccessoryView = stackView
            
            let rightButton = UIButton(type: .detailDisclosure)
            markerAnnotationView.rightCalloutAccessoryView = rightButton
        }
        
        return view
    }

    // https://developer.apple.com/documentation/mapkit/mapkit_annotations/annotating_a_map_with_custom_data
    // without using detailCalloutAccessoryView
    private func setupAnnotationView2(for annotation: Sight, on mapView: MKMapView) -> MKAnnotationView {
        let reuseIdentifier = NSStringFromClass(Sight.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
        
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.canShowCallout = true
            markerAnnotationView.displayPriority = .required
            
            markerAnnotationView.glyphImage = UIImage(named: "church")
            
            // Provide the annotation view's image.
            //        markerAnnotationView.image = image
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
