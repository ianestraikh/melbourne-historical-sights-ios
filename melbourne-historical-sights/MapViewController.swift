//
//  MapViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 17/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, DatabaseListener {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var sights: [Sight] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

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
            let destination = segue.destination as! SightsTableViewController
            //destination.delegate = self
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
