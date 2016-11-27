//
//  WelcomeViewController.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        loginButton.layer.borderColor = UIColor(hex: "007AFF").cgColor
        loginButton.layer.borderWidth = CGFloat(1.0)
        loginButton.layer.cornerRadius = 3.0
        loginButton.layer.masksToBounds = true
        
        signupButton.layer.cornerRadius = 3.0
        signupButton.layer.masksToBounds = true
    }

}
