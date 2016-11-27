//
//  CreateNewTeamViewController.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse
import Photos
import Spring

class CreateNewTeamViewController: UIViewController {
    
    @IBOutlet weak var teamFeaturedImage: UIImageView!
    @IBOutlet weak var newTeamIdTextField: UITextField!
    @IBOutlet weak var containerView: DesignableView!
    
    fileprivate var featuredImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        newTeamIdTextField.becomeFirstResponder()
        
        // make the featured image view a round image
        teamFeaturedImage.layer.cornerRadius = teamFeaturedImage.bounds.width / 2.0
        teamFeaturedImage.layer.masksToBounds = true
    }
    
    @IBAction func createNewTeamClicked(sender: AnyObject) {
        
        if self.newTeamIdTextField.text!.length < 6 || featuredImage == nil {
            shake()
        } else {
            // let's create a new team
            let query = PFQuery(className: Team.parseClassName())
            query.whereKey("title", equalTo: newTeamIdTextField.text!)
            query.cachePolicy = .networkElseCache
            
            query.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    if let objects = objects as [PFObject]! {
                        if objects.count > 0 {
                            // there's already a team with this title in the Team class on Parse
                            self.shake()
                            return
                        } else {
                            
                            // create new team
                            let newTeam = Team(title: self.newTeamIdTextField.text!, featuredImage: self.featuredImage, newMemberId: User.current()!.objectId!)
                            newTeam.saveInBackground(block: { (success, error) -> Void in
                                if error == nil {
                                    User.current()!.currentTeamId = newTeam.objectId!
                                    User.current()!.saveInBackground()
                                    
                                    self.dismiss(animated: true, completion: nil)
                                } else {
                                    print(error!.localizedDescription)
                                }
                            })
                            
                        }
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    @IBAction func pickFeaturedImageClicked(sender: UITapGestureRecognizer) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                
                DispatchQueue.main.async {
                    self.pickFeaturedImageClicked(sender: sender)
                }
                
            })
            return
        }
        
        if authorization == .authorized {
            let controller = ImagePickerSheetController()
            
            controller.addAction(ImageAction(title: NSLocalizedString("Take Photo or Video", comment: "ActionTitle"),
                                             secondaryTitle: NSLocalizedString("Use this one", comment: "Action Title"),
                                             handler: { (_) -> () in
                                                
                                                self.presentCamera()
                                                
            }, secondaryHandler: { (action, numberOfPhotos) -> () in
                controller.getSelectedImagesWithCompletion({ (images) -> Void in
                    self.featuredImage = images[0]
                    self.teamFeaturedImage.image = self.featuredImage
                })
            }))
            
            controller.addAction(ImageAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .Cancel, handler: nil, secondaryHandler: nil))
            
            presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func shake() {
        containerView.animation = "shake"
        containerView.curve = "spring"
        containerView.duration = 1.0
        containerView.animate()
    }
    
}

extension CreateNewTeamViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentCamera() {
        // CHALLENGE: present normla image picker controller
        //              update the postImage + postImageView
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.featuredImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.teamFeaturedImage.image! = self.featuredImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}









