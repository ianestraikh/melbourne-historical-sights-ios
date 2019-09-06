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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    
    weak var sight: Sight?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDetails()
    }
    
    func updateDetails() {
        if let imageFilename = sight!.imageFilename {
            let img = loadImageData(filename: imageFilename)
            imageView.image = img
        }
        
        self.nameLabel.text = sight!.name
        self.descLabel.text = sight!.desc
        
        getAddressFromLatLon(lat: sight!.latitude, lon: sight!.longitude)
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
    
    // get address by lat and long
    // https://stackoverflow.com/questions/41358423/swift-generate-an-address-format-from-reverse-geocoding
    func getAddressFromLatLon(lat: Double, lon: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                
                if pm.count > 0 {
                    let pm = placemarks![0]
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    
                    self.locationLabel.text = addressString
                }
        })
        
    }
}
