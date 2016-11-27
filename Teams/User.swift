//
//  User.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse



public class User: PFUser {
    
    @NSManaged public var profileImageFile: PFFile!
    @NSManaged public var currentTeamId: String!

    
    init(username: String, password: String, email: String, image: UIImage) {
        super.init()
        
        let imageFile = image.createPFFile()
        
        self.profileImageFile = imageFile
        self.username = username
        self.password = password
        self.email = email
    }
    
    
    
    
}
























