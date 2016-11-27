//
//  SignupPasswordViewController.swift
//  Taggs
//
//  Created by nag on 25/09/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

class SignupPasswordViewController: UIViewController {
    
    var email: String!
    
    fileprivate var password: String!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var containerView: DesignableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if passwordTextField.text!.isEmpty || passwordTextField.text!.length < 6 {
            shake()
        } else {
            
            password = passwordTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            password = password.lowercased()
            
            performSegue(withIdentifier: "ShowSignupProfile", sender: nil)
            
        }
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func shake() {
        containerView.animation = "shake"
        containerView.curve = "spring"
        containerView.duration = 1.0
        containerView.animate()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSignupProfile" {
            let signupProfileVC = segue.destination as! SignupProfileViewController
            signupProfileVC.password = password
            signupProfileVC.email = email
        }
    }

    
}
