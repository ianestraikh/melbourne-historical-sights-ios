//
//  AddEditSightViewController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 22/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit

class EditSightViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        
        // Prevent keyboard overlapping text field
        // https://stackoverflow.com/questions/26689232/scrollview-and-keyboard-swift/50829480
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @IBAction func setLocation(_ sender: Any) {
    }
    
    @IBAction func saveSight(_ sender: Any) {
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //displayMessage("There was an error in getting the image", "Error", picker)
    }
    
    // TODO: when the cancel button is clicked at imagePickerController the message appears, but the window is not being canceled
    func displayMessage(_ message: String,_ title: String, _ obj: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        obj.present(alertController, animated: true, completion: nil)
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
