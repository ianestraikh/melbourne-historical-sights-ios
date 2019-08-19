//
//  SightViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 19/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit

class SightViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    weak var sight: Sight?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let imageFilename = sight!.imageFilename {
            let img = loadImageData(filename: imageFilename)
            imageView.image = img
        }
        
        sight!.name = "changed"
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
