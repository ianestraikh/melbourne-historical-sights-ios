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
    @IBOutlet weak var markerImageView: UIImageView!
    @IBOutlet weak var glyphimageImageView: UIImageView!
    
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
    
    
    var tempImageView: UIImageView?
    
    var coordinate: CLLocationCoordinate2D?
    
    var selectedGlyphimage = 0
    var selectedColor = 0
    
    weak var sight: Sight?
    
    weak var databaseController: DatabaseProtocol?
    
    var isImageChanged: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dismiss keyboard by tapping somewhere in view
        // https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        // Edit sight if it is not nil
        if sight != nil {
            let img = loadImageData(filename: sight!.imageFilename!)
            imageView.image = img
            
            self.nameTextField.text = sight!.name
            self.descTextView.text = sight!.desc
            
            self.selectedColor = Int(sight!.color)
            self.selectedGlyphimage = Int(sight!.glyphimage)
            
            coordinate = CLLocationCoordinate2D(latitude: sight!.latitude, longitude: sight!.longitude)
        } else {
            imageViewAspectRatioConstraint = imageViewAspectRatioConstraint.setMultiplier(multiplier: 0)
            imageView.layoutIfNeeded()
        }
        
        setupMarkerAppearance(selectedColor: selectedColor, selectedGlyphimage: selectedGlyphimage)
        
        // Make text view look like text field
        // https://stackoverflow.com/questions/1824463/how-to-style-uitextview-to-like-rounded-rect-text-field
        descTextView.layer.cornerRadius = 5
        descTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descTextView.layer.borderWidth = 0.5
        descTextView.clipsToBounds = true
    }
    
    // https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        // Prevent keyboard overlapping text field
        // https://stackoverflow.com/questions/26689232/scrollview-and-keyboard-swift/50829480
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
        if imageViewAspectRatioConstraint != nil {
            imageView.removeConstraint(imageViewAspectRatioConstraint)
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: imageView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0))
            imageView.layoutIfNeeded()
        }
        
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
        
        if coordinate == nil {
            displayMessage("Set location first", "Error", self)
            return
        }
        
        if sight != nil {
            databaseController?.updateSight(sight: sight!, name: nameTextField.text!, desc: descTextView.text, latitude: coordinate!.latitude, longitude: coordinate!.longitude, imageFilename: nil, color: Int16(self.selectedColor), glyphimage: Int16(self.selectedGlyphimage))
            
            if isImageChanged {
                let image = imageView.image
                let data = image!.jpegData(compressionQuality: 0.8)!
                deleteImageFromDocumentDirectory(imageFilename: sight!.imageFilename!)
                saveImageToDocumentDirectory(data: data, imageFilename: sight!.imageFilename!)
            }
        } else {
            guard let image = imageView.image else {
                displayMessage("Cannot save until a photo has been taken!", "Error", self)
                return
            }
            
            let date = UInt(Date().timeIntervalSince1970)
            let data = image.jpegData(compressionQuality: 0.8)!
            saveImageToDocumentDirectory(data: data, imageFilename: "\(date)")
            
            let _ = databaseController?.addSight(name: nameTextField.text!, desc: descTextView.text, latitude: coordinate!.latitude, longitude: coordinate!.longitude, imageFilename: "\(date)", color: Int16(self.selectedColor), glyphimage: Int16(self.selectedGlyphimage))
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
            isImageChanged = true
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setLocationSegue" {
            let destination = segue.destination as! SetLocationViewController
            destination.editSightViewController = sender as? EditSightViewController
        }
    }
    
    @IBAction func setLocation(_ sender: Any) {
        performSegue(withIdentifier: "setLocationSegue", sender: self)
    }
}
