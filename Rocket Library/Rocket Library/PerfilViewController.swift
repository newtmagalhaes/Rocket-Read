//
//  PerfilViewController.swift
//  Rocket Library
//
//  Created by Anilton Magalhães on 24/01/20.
//  Copyright © 2020 Rocket Team. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import GoogleSignIn

class PerfilViewController: UIViewController {
    
    var window: UIWindow?
    
    @IBOutlet weak var SignOutButton: UIButton!
    
    @IBOutlet weak var userEmail: UILabel!
    
    @IBOutlet weak var UserImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserImage.layer.cornerRadius = UserImage.frame.size.width / 2
        
        let usuario = Auth.auth().currentUser
        userEmail.text = usuario?.email
        
        // GET user.photoURL e SET na tela
        URLSession.shared.dataTask(with: (usuario?.photoURL)!) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.UserImage.image = UIImage(data: data!)
            }
            print("Setando a imagem de usuário")
        }.resume()
        
    }
    
    @IBAction func signOutGoogle(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? ViewController {
                
                UIApplication.shared.keyWindow?.rootViewController = loginViewController
                
            } else {
                print("EROU")
            }
             
            
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        print("usuário deslogado")
        // MARK: - TODO: SEGUE LOGIN
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    }
