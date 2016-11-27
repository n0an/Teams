//
//  LoginPasswordViewController.swift
//  Taggs
//
//  Created by nag on 25/09/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//


import UIKit
import Parse

class LoginPasswordViewController: UIViewController {
    
    var email: String!
    fileprivate var password: String!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        passwordTextField.becomeFirstResponder()
    }
    
    func setupUserInstallation() {
        let installation = PFInstallation.current()
        installation!["user"] = PFUser.current()
        installation?.saveInBackground()
        
    }
    
    @IBAction func logInClicked(_ sender: UIButton) {
        
        let password = passwordTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        PFUser.logInWithUsername(inBackground: email, password: password!) { (user, error) in
            if error == nil {
                
                self.setupUserInstallation()
                
                self.dismiss(animated: true, completion: nil)
                
                
            } else {
                print("\(error?.localizedDescription)")
            }
            
        }
        
    }
    
    @IBAction func backButtonClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
