//
//  SightViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 19/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import MapKit

class SightDetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: MKMapView!
    
    weak var sight: Sight?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDetails()
    }
    
    func updateDetails() {
        mapView.removeAnnotations(mapView.annotations)
        
        if let imageFilename = sight!.imageFilename {
            let img = loadImageData(filename: imageFilename)
            imageView.image = img
        }
        
        self.name.text = sight!.name
        self.desc.text = sight!.desc
        
        // https://stackoverflow.com/questions/9891926/quickly-adding-single-pin-to-mkmapview
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: sight!.latitude, longitude: sight!.longitude)
        annotation.coordinate = centerCoordinate
        annotation.title = sight!.name
        mapView.addAnnotation(annotation)
        focusOn(mapView: mapView, annotation: annotation)
    }
    
    @IBAction func editSight(_ sender: Any) {
        performSegue(withIdentifier: "editSightSegue", sender: sight)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSightSegue" {
            let destination = segue.destination as! EditSightViewController
            destination.sight = sender as? Sight
        }
    }
}
