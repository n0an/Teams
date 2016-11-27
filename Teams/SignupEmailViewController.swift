//
//  SignupEmailViewController.swift
//  Taggs
//
//  Created by nag on 25/09/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Spring

class SignupEmailViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var containerView: DesignableView!
    
    fileprivate var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if emailTextField.text!.isEmpty || emailTextField.text!.length < 6 {
            shake()
        } else {
            
            email = emailTextField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
            
            email = email.lowercased()
            
            performSegue(withIdentifier: "ShowSignupPassword", sender: nil)
            
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
        if segue.identifier == "ShowSignupPassword" {
            let signupPasswordVC = segue.destination as! SignupPasswordViewController
            signupPasswordVC.email = email

        }
    }
    
    
}






















