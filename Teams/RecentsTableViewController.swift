//
//  RecentsTableViewController.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class RecentsTableViewController: UITableViewController {

    @IBOutlet weak var logOutBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if User.current() == nil {
            showLogin()
        }
    }
    
    
    func showLogin() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let welcomeNavigationVC = storyboard.instantiateViewController(withIdentifier: "WelcomeNavigationViewController") as! UINavigationController
        self.present(welcomeNavigationVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = self.logOutBarButtonItem
        
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
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    

}
