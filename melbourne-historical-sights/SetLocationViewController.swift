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
    weak var editSightViewController: EditSightViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editSightViewController!.coordinate != nil {
            let zoomRegion = MKCoordinateRegion(center: editSightViewController!.coordinate!, latitudinalMeters: 1000, longitudinalMeters: 1000)
            setLocationMapView.setRegion(setLocationMapView.regionThatFits(zoomRegion), animated: true)
        } else {
            centerMapOnMelbourne(mapView: setLocationMapView)
        }
        setLocationMapView.showsUserLocation = true;
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    @IBAction func done(_ sender: Any) {
        editSightViewController!.coordinate = setLocationMapView.centerCoordinate
        navigationController?.popViewController(animated: true)
    }
}
