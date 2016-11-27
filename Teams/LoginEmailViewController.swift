//
//  LoginEmailViewController.swift
//  Taggs
//
//  Created by nag on 25/09/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class LoginEmailViewController: UIViewController {
    
    fileprivate var email: String!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        
        email = emailTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        email = email.lowercased()
        
        performSegue(withIdentifier: "ShowLoginPassword", sender: nil)

    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLoginPassword" {
            let loginPasswordVC = segue.destination as! LoginPasswordViewController
            loginPasswordVC.email = email
            
        }
    }

    
    
    
}
