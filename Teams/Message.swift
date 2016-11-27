//
//  Message.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

public class Message: PFObject, PFSubclassing {
    
    // MARK: - Public API
    @NSManaged public var text: String!
    @NSManaged public var photoFile: PFFile!
    @NSManaged public var sender: PFUser!
    @NSManaged public var conversationId: String!
    
    // MARK: - Create New Message
    
    // text message
    
    init(text: String, sender: PFUser, conversationId: String) {
        super.init()
        self.text = text
        self.sender = sender
        self.conversationId = conversationId
    }
    
    // photo message
    
    init(photo: UIImage, sender: PFUser, conversationId: String) {
        super.init()
        self.photoFile = photo.createPFFile()
        self.sender = sender
        self.conversationId = conversationId
    }
    
    override init() {
        super.init()
    }
    
    
    // MARK: - PFSubclassing
        public static func parseClassName() -> String {
        return "Message"
    }
}


