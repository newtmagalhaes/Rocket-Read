//
//  ViewController.swift
//  Rocket Library
//
//  Created by Lucas Dantas on 17/01/20.
//  Copyright © 2020 Rocket Team. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController {
    
    @IBOutlet weak var GoogleButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
}

