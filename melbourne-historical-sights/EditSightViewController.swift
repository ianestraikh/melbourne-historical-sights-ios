//
//  AddEditSightViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 22/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import MapKit

class EditSightViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DatabaseListener {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var markerImageView: UIImageView!
    @IBOutlet weak var glyphimageImageView: UIImageView!
    
    var selectedGlyphimage = 0
    var selectedColor = 0
    var imageFilename: String?
    
    weak var sight: Sight?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Edit sight if it is not nil
        if sight != nil {
            if let imageFilename = sight!.imageFilename {
                let img = loadImageData(filename: imageFilename)
                imageView.image = img
            }
            
            self.nameTextField.text = sight!.name
            self.descTextView.text = sight!.desc
            
            focusOn(mapView: mapView, annotation: sight!)
            
            self.selectedColor = Int(sight!.color)
            self.selectedGlyphimage = Int(sight!.glyphimage)
            
            self.imageFilename = sight!.imageFilename
        } else {
            centerMapOnMelbourne(mapView: mapView)
        }
        
        setupMarkerAppearance(selectedColor: selectedColor, selectedGlyphimage: selectedGlyphimage)
        
        // Make text view look like text field
        // https://stackoverflow.com/questions/1824463/how-to-style-uitextview-to-like-rounded-rect-text-field
        descTextView.layer.cornerRadius = 5
        descTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descTextView.layer.borderWidth = 0.5
        descTextView.clipsToBounds = true
        
        // Prevent keyboard overlapping text field
        // https://stackoverflow.com/questions/26689232/scrollview-and-keyboard-swift/50829480
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func setupMarkerAppearance(selectedColor: Int, selectedGlyphimage: Int) {
        markerImageView.tintColor = MARKER_COLORS[selectedColor]
        glyphimageImageView.image = UIImage(named: GLYPHIMAGES[selectedGlyphimage])
        glyphimageImageView.tintColor = UIColor.white
    }
    
    // https://stackoverflow.com/questions/26689232/scrollview-and-keyboard-swift/50829480
    @objc func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func saveSight(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else {
            displayMessage("Name cannot be emtpy", "Error", self)
            return
        }
        guard let desc = descTextView.text, !desc.isEmpty else {
            displayMessage("Description cannot be emtpy", "Error", self)
            return
        }
        
        let lat = mapView.centerCoordinate.latitude
        let lon = mapView.centerCoordinate.longitude
        
        if sight != nil {
            sight!.name = nameTextField.text
            sight!.desc = descTextView.text
            sight!.imageFilename = self.imageFilename
            sight!.color = Int16(self.selectedColor)
            sight!.glyphimage = Int16(self.selectedGlyphimage)
            sight!.latitude = lat
            sight!.longitude = lon
            
            databaseController?.saveContext()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func markerTapGestureRecogniser(_ sender: Any) {
        if selectedGlyphimage == GLYPHIMAGES.count - 1 {
            selectedGlyphimage = 0
        } else {
            selectedGlyphimage += 1
        }
        glyphimageImageView.image = UIImage(named: GLYPHIMAGES[selectedGlyphimage])
    }
    
    @IBAction func markerLongPressGestureRecogniser(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if selectedColor == MARKER_COLORS.count - 1 {
                selectedColor = 0
            } else {
                selectedColor += 1
            }
            markerImageView.tintColor = MARKER_COLORS[selectedColor]
        }
    }
    
    func onSightListChange(change: DatabaseChange, sights: [Sight]) {
    }
}
