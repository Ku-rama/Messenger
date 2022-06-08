//
//  ViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 01/06/22.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class ConversationsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
//        if AccessToken.current == nil{
//            print("Token is nil")
//        }else{
//            print("Access Token is here, \(AccessToken.current)")
//        }
//        print(Auth.auth().currentUser?.uid)
        print("Finish")
        if let token = AccessToken.current,
           !token.isExpired{
            // User is logged in, do work such as go to next view controller.
            print("User is loggged in with facebook")
            
        }
        validateAuth()
    }
    
    private func validateAuth(){
        if Firebase.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

