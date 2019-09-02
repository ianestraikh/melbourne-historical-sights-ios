//
//  SetLocationViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 2/9/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import MapKit

class SetLocationViewController: UIViewController {
    @IBOutlet weak var setLocationMapView: MKMapView!
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.coordinate != nil {
            let zoomRegion = MKCoordinateRegion(center: self.coordinate!, latitudinalMeters: 1000, longitudinalMeters: 1000)
            setLocationMapView.setRegion(setLocationMapView.regionThatFits(zoomRegion), animated: true)
        } else {
            centerMapOnMelbourne(mapView: setLocationMapView)
        }
        
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    @IBAction func setLocation(_ sender: Any) {
        self.coordinate = setLocationMapView.centerCoordinate
        
        navigationController?.popViewController(animated: true)
    }
}
