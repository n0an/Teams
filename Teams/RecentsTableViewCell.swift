//
//  RecentsTableViewCell.swift
//  Teams
//
//  Created by nag on 28/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class RecentsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    // Public API
    var conversation: Conversation! {
        didSet {
            updateUI()
        }
    }
    
    let currentUser = PFUser.current() as! User
    
    
    func updateUI() {
        
        let user1 = self.conversation.user1 as! User
        let user2 = self.conversation.user2 as! User
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        // -- We've got conversation now
        // 1. Fetch messages with this conversation id
        
        let messageQuery = PFQuery(className: Message.parseClassName())
        messageQuery.whereKey("conversationId", equalTo: conversation.objectId!)
        messageQuery.order(byDescending: "createdAt")
//        messageQuery.order(byAscending: "createdAt")
        messageQuery.limit = 1
        messageQuery.includeKey("sender")

        
        messageQuery.findObjectsInBackground { (objects, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            // * THERE'S NO MESSAGES IN CONVERSATION *
            if objects?.count == 0 {
                // -- No messages in conversation
                // 1) Put "Send First Message" to lastMessageLabel
                
                self.lastMessageLabel.text = "*** Send First Message"

                // 2) Put lastUpdate date from conversation
                
                let conversationDate = self.conversation.lastUpdate as Date
                
                self.timeStampLabel.text = dateFormatter.string(from: conversationDate)

                // 3) Put usernameLabel and put profile image to profile image (self image if it's conversation with self)
                
                self.configureUserNameLabelAndProfileImage(forUser1: user1, user2: user2)
                
                
                // * THERE'RE MESSAGES IN CONVERSATION *
            } else if let objects = objects as [PFObject]! {
                
                if objects.count > 0 {
                    
                    // 1. Take last message

                    let lastMessage = objects.first as! Message
                    
                    // 2. Put text of last message to lastMessageLabel
                    self.lastMessageLabel.text = lastMessage.text
                    
                    // 3. Put date of message to timeStampLabel
                                        
                    let messageDate = lastMessage.createdAt!
                    self.timeStampLabel.text = dateFormatter.string(from: messageDate)
                    
                    // 4. Get recipient of conversation: self or another person, configure userNameLabel and profileImageView
                    
                    self.configureUserNameLabelAndProfileImage(forUser1: user1, user2: user2)
                    
                }
     
            }
            
            
        }
        
        
    }
    
    
    
    
    func configureUserNameLabelAndProfileImage(forUser1 user1: User, user2: User) {
        
        if user1.objectId == user2.objectId {
            // Conversation with the self. Show current user in profileImage
            
            self.userNameLabel.text = currentUser.username
            
            downloadProfileImage(forUser: currentUser)
            
        } else {
            // Conversation with another person. Show recipient user in profileImage
            
            if user1.objectId == currentUser.objectId {
                // Show user2 profileImage
                
                self.userNameLabel.text = user2.username
                
                downloadProfileImage(forUser: user2)
                
            } else {
                // SHow user1 profileImage
                
                self.userNameLabel.text = user1.username
                
                downloadProfileImage(forUser: user1)
            }
        }
        
        
    }
    
    
    
    func downloadProfileImage(forUser user: User) {
        user.profileImageFile.getDataInBackground(block: { (data, error) in
            
            if let data = data {
                
                if let image = UIImage(data: data) {
                    self.profileImageView.image = image
                    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2.0
                    self.profileImageView.layer.masksToBounds = true
                }
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    

}
