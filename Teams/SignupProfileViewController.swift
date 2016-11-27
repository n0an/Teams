//
//  SignupProfileViewController.swift
//  Taggs
//
//  Created by nag on 25/09/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Photos
import Spring
import Parse

class SignupProfileViewController: UIViewController {
    
    var email: String!
    var password: String!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var containerView: DesignableView!
    
    fileprivate var profileImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.profileImage = userProfileImageView.image
        
        self.view.layoutIfNeeded()
        
        usernameTextField.becomeFirstResponder()
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.bounds.width / 2
        userProfileImageView.layer.masksToBounds = true
    }
    
    
    
    
    @IBAction func pickProfileImage(_ tap: UITapGestureRecognizer) {
        
        
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    self.pickProfileImage(tap)
                }
            })
            return
        }
        
        if authorization == .authorized {
            self.presentImagePicker()
        }
        
        
        
    }

    func setupUserInstallation() {
        let installation = PFInstallation.current()
        installation!["user"] = PFUser.current()
        installation?.saveInBackground()
        
    }
    
    func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        
        self.present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    @IBAction func signUpButtonClicked() {
        
        if userProfileImageView.image == nil || usernameTextField.text!.length < 6 {
            // animate
            shake()
        } else {
            
            
            let username = usernameTextField.text!
            
            let newUser = User(username: username, password: password, email: email, image: profileImage)
            
            newUser.signUpInBackground(block: { (success, error) -> Void in
                
                if error == nil {
                    
                    self.setupUserInstallation()
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    
                } else {
                    print("\(error?.localizedDescription)")
                }
            })
        }
    }
    
    @IBAction func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func shake() {
        containerView.animation = "shake"
        containerView.curve = "spring"
        containerView.duration = 1.0
        containerView.animate()
    }
    
}



extension SignupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.profileImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.userProfileImageView.image! = self.profileImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}






