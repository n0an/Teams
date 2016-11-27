//
//  ContactTableViewCell.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var onlineIndicatorView: UIView!
    
    var user: User! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        // (1) download the profile image
        // asynchronous
        user.profileImageFile.getDataInBackground { (data, error) -> Void in
            if error == nil {
                if let data = data {
                    if let image = UIImage(data: data) {
                        self.profileImageView.image = image
                        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2.0
                        self.profileImageView.layer.masksToBounds = true
                    }
                }
            }
        }
        
        // (2) populate the user's username
        usernameLabel.text! = user.username!
        
        // (3) show the user is online or offline
        onlineIndicatorView?.layer.cornerRadius = (onlineIndicatorView?.bounds.width)! / 2.0
        onlineIndicatorView?.layer.masksToBounds = true
        
        if user.objectId! == User.current()!.objectId! {
            onlineIndicatorView?.isHidden = false
        } else {
            let currentTeamId = User.current()!.currentTeamId
            if user.currentTeamId != nil && user.currentTeamId == currentTeamId {
                onlineIndicatorView?.isHidden = false
            } else {
                onlineIndicatorView?.isHidden = true
            }
        }
    }
    
}
