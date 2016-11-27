//
//  JoinTeamViewController.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse
import Spring

class JoinTeamViewController: UIViewController {

    @IBOutlet weak var containerView: DesignableView!
    @IBOutlet weak var teamIdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        teamIdTextField.becomeFirstResponder()
    }
    
    @IBAction func join(sender: AnyObject) {
        // create a query into the Team class on Parse
        let query = PFQuery(className: Team.parseClassName())
        // we want to find the team that has the same id as the team the user wants to join
        query.whereKey("title", equalTo: teamIdTextField.text!)
        query.cachePolicy = .networkElseCache   // just to have cache feature running in case the user is out of the network
        query.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                if let objects = objects as [PFObject]! {
                    if objects.count > 0 {
                        // there's a team. we use objects.first just to be safe. objects.first returns the first object in the array, if there isn't any object, it doesn't crash our app
                        if let team = objects.first as? Team {
                            // join the team
                            team.addNewMemberWithId(newMemberId: User.current()!.objectId!)
                            
                            // update the currentTeamId of the current user
                            User.current()!.currentTeamId = team.objectId!
                            User.current()!.saveInBackground()  // whenever we update any field in a PFObject - User is a PFUser, which is also a PFObject - we need to save it in background
                            
                            // the reason why we need to save in background is that it doesn't block the main thread (queue). saveInBackground is asynchronous. It does its job in a different thread. The main thread is for UI code only. And UI code MUST be executed in the main thread only.
                            
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        self.shake()    // there's no such team, shake things up
                    }
                }
            } else {
                // probably you should show an alert view here. do somethign cool, sensitive!
                print("\(error?.localizedDescription)")
            }
        }
    }
    
    func shake() {
        containerView.animation = "shake"
        containerView.curve = "spring"
        containerView.duration = 1.0
        containerView.animate()
    }
}
