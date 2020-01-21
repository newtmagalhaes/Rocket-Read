//
//  ViewController.swift
//  Rocketshelf
//
//  Created by Anilton Magalhães on 21/01/20.
//  Copyright © 2020 Anilton Magalhães. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController {

    
    
    @IBOutlet weak var GIDSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }


}

