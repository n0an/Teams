//
//  Team.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

public class Team: PFObject, PFSubclassing {
    
    // MARK: - Public API
    @NSManaged public var title: String!
    @NSManaged public var numberOfMembers: Int
    @NSManaged public var featuredImageFile: PFFile!
    @NSManaged public var memberIds: [String]!
    

    // MARK: - Create new team
    
    init(title: String, featuredImage: UIImage, newMemberId: String) {
        super.init()
        
        self.title = title
        self.featuredImageFile = featuredImage.createPFFile()
        self.memberIds = [newMemberId]  // an array contains only one element
        numberOfMembers = 1
    }
    
    override init() {
        super.init()
    }
    

    
    // MARK: - Modify
    
    public func addNewMemberWithId(newMemberId: String) {
        
        if !memberIds.contains(newMemberId) {
            memberIds.insert(newMemberId, at: 0)
            numberOfMembers += 1
            self.saveInBackground()
        }
    }
    
    public func takeOutMemberWithId(memberId: String) {
        
        if let index = memberIds.index(of: memberId) {
            memberIds.remove(at: index)
            numberOfMembers -= 1
            
            self.saveInBackground()
        }
    }
    
    
    public func changeFeaturedImage(image: UIImage) {
        self.featuredImageFile = image.createPFFile()
        self.saveInBackground()
    }

    
    
    
    // Method to conform to PFSubclassing protocol
    public static func parseClassName() -> String {
        return "Team"
    }
    
    
    
    
    
}














