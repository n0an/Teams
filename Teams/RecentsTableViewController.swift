//
//  RecentsTableViewController.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class RecentsTableViewController: UITableViewController {

    @IBOutlet weak var logOutBarButtonItem: UIBarButtonItem!
    
    var teamId: String!
    
    var conversations = [Conversation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.logOutBarButtonItem
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard User.current() != nil else {
            showLogin()
            return
        }
        
        
        if teamId == nil {
            teamId = User.current()?.currentTeamId
        }
        
        
        loadConversations()

        
    }
    
    func showLogin() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeNavigationVC = storyboard.instantiateViewController(withIdentifier: "WelcomeNavigationViewController") as! UINavigationController
        self.present(welcomeNavigationVC, animated: true, completion: nil)
    }
    
    func loadConversations() {
      
        let currentUser = User.current()!
        
        let predicate = NSPredicate(format: "user1 = %@ OR user2 = %@", currentUser, currentUser)
        
        // find an existing conversations
   
        let conversationQuery = PFQuery(className: Conversation.parseClassName(), predicate: predicate)
        
        conversationQuery.cachePolicy = .networkElseCache
        
        conversationQuery.includeKeys(["user1", "user2"])
        
        conversationQuery.whereKey("teamId", equalTo: teamId)
        
        conversationQuery.findObjectsInBackground { (objects, error) in
            
            if error != nil {
                print(error!.localizedDescription)
            } else {
                
                self.conversations.removeAll()
                
                if let objects = objects as [PFObject]! {
                    
                    for object in objects {
                        
                        let conversation = object as! Conversation
                        
                        self.conversations.append(conversation)

                    }
                    
                    self.tableView.reloadData()
                    
                    
                    
                }
                
                
            }
            
            
        }
        
        
        
    }
    
    @IBAction func logOutClicked(sender: AnyObject) {
        
        User.current()?.currentTeamId = ""
        User.current()?.saveInBackground(block: { (success, error) -> Void in
            if success {
                User.logOut()
                self.showLogin()
            } else {
                //
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsTableViewCell", for: indexPath) as! RecentsTableViewCell
        
        let conversation = self.conversations[indexPath.row]
        
        cell.conversation = conversation
        
        return cell
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 81.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let selectedConversation = self.conversations[indexPath.row]
        
        let user1 = selectedConversation.user1 as! User
        let user2 = selectedConversation.user2 as! User
        
        let currentUser = User.current()!
        
        
        var incomingUser: User
        
        if user1 == user2 {
            incomingUser = currentUser
        } else {
            if currentUser == user1 {
                incomingUser = user2
            } else {
                incomingUser = user1
            }
        }
        
        
        // instantiate MessagesViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesViewController") as! MessagesViewController
        
        messagesVC.conversation = selectedConversation
        messagesVC.incomingUser = incomingUser
        
        messagesVC.hidesBottomBarWhenPushed = true
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.navigationController?.pushViewController(messagesVC, animated: true)
        
        
    }

    

}










