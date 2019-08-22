//
//  AddEditSightViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 22/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit

class AddEditSightViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    
    weak var sight: Sight?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Edit sight if it is not nil
        if sight != nil {
            if let imageFilename = sight!.imageFilename {
                let img = loadImageData(filename: imageFilename)
                imageView.image = img
            }
            
            self.nameTextField.text = sight!.name
            self.descTextView.text = sight!.desc
        }
        
        // Make text view look like text field
        // https://stackoverflow.com/questions/1824463/how-to-style-uitextview-to-like-rounded-rect-text-field
        descTextView.layer.cornerRadius = 5
        descTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descTextView.layer.borderWidth = 0.5
        descTextView.clipsToBounds = true
    }
    
    @IBAction func takePhoto(_ sender: Any) {
    }
    
    @IBAction func setLocation(_ sender: Any) {
    }
    
    @IBAction func saveSight(_ sender: Any) {
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
