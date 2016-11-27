//
//  Conversation.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse


public class Conversation: PFObject, PFSubclassing {
    
    // MARK: - Public API
    @NSManaged public var teamId: String!
    @NSManaged public var user1: PFUser!
    @NSManaged public var user2: PFUser!
    @NSManaged public var lastUpdate: NSDate
    
    // MARK: - Create new conversation
    
    init(teamId: String, user1: PFUser, user2: PFUser) {
        
        super.init()
        
        self.teamId = teamId
        self.user1 = user1
        self.user2 = user2
        self.lastUpdate = NSDate()
    }
    
    
    // MARK: - PFSubclassing
    
    public static func parseClassName() -> String {
        return "Conversation"
    }
    
    
}


































