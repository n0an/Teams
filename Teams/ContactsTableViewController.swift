//
//  ContactsTableViewController.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class ContactsTableViewController: UITableViewController {
    var teamId: String!
    var users = [User]()        // datasource
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if teamId == nil {
            teamId = User.current()!.currentTeamId
        }
        fetchUsers()
    }
    
    func fetchUsers() {
        let teamQuery = PFQuery(className: Team.parseClassName())
        teamQuery.cachePolicy = .networkElseCache
        
        teamQuery.getObjectInBackground(withId: teamId) { (object, error) -> Void in
            if error == nil {
                if let team = object as? Team {
                    if let memberIds = team.memberIds {
                        
                        let query = User.query()!
                        query.whereKey("objectId", containedIn: memberIds)
                        query.findObjectsInBackground(block: { (objects, error) -> Void in
                            if let objects = objects as [PFObject]! {
                                self.users.removeAll()
                                
                                for object in objects {
                                    let user = object as! User
                                    self.users.append(user)
                                }
                                
                                self.tableView.reloadData()
                            }
                        })
                        
                    }
                }
            } else {
                print("\(error?.localizedDescription)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Contacts"
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        
        cell.user = self.users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 57.0
    }
    

    
    
}
