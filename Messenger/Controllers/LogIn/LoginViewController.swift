//
//  LoginViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 01/06/22.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "iMessageLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .continue
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
        
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        tf.leftViewMode = .always
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    private lazy var logInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var FBlogInButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    private let googleSignInButton : GIDSignInButton = {
        let button = GIDSignInButton()
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    
    private var logInObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        logInObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main) { [weak self]_ in
            guard let strongSelf = self else{
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
        GIDSignIn.sharedInstance().presentingViewController = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(logInButton)
        scrollView.addSubview(FBlogInButton)
        scrollView.addSubview(googleSignInButton)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        FBlogInButton.delegate = self
    }
    
    deinit{
        if let logInObserver = logInObserver {
            NotificationCenter.default.removeObserver(logInObserver)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        logoImageView.frame = CGRect(x: (view.width-size)/2,
                                     y: 20,
                                     width: size,
                                     height: size)
        emailTextField.frame = CGRect(x: 30,
                                      y: logoImageView.bottom+30,
                                      width: scrollView.width-60,
                                      height: 52)
        passwordTextField.frame = CGRect(x: 30,
                                         y: emailTextField.bottom+20,
                                         width: scrollView.width-60,
                                         height: 52)
        logInButton.frame = CGRect(x: 30,
                                   y: passwordTextField.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
        FBlogInButton.frame = CGRect(x: 30,
                                     y: logInButton.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        googleSignInButton.frame = CGRect(x: 30,
                                          y: FBlogInButton.bottom+20,
                                          width: scrollView.width-60,
                                          height: 52)
        
    }
    
    
    @objc func loginButtonTapped(){
        spinner.show(in: view)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else{
            alertUserLogInError()
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) {
            [weak self] authResult, err in
            guard let strongSelf = self else{
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            guard let result = authResult, err == nil else{
                print("Failed to sign in. \(String(describing: err))")
                return
            }
            print("Successfully loggedin user", result)
            strongSelf.navigationController?.dismiss(animated: true)
        }
    }
    
    func alertUserLogInError(){
        let alert = UIAlertController(title: "Woops", message: "Please enter all information to log in.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc private func didTapRegister(){
        
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordTextField.becomeFirstResponder()
        }else if textField == passwordTextField{
            loginButtonTapped()
        }
        return true
    }
    
}

extension LoginViewController: LoginButtonDelegate{
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("User failed to login with facebook.")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"] , tokenString: token, version: "v14.0", httpMethod: HTTPMethod.get)
        
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else{
                print("Failed to make facebook graph request")
                return
            }
            
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any], let pictureUrl = data["url"] as? String else{
                print("Failed to ger username and email")
                return
            }
            
            print(result)
            
            DatabaseManager.shared.validateNewUser(with: email) { exists in
                if !exists{
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser) { success in
                        if success{
                            
                            guard let url = URL(string: pictureUrl) else{
                                return
                            }
                            print("Downloding data from facebook.")
                            
                            URLSession.shared.dataTask(with: url) { data, _, error in
                                guard let data = data else{
                                    print("Failed to get data from facebook.")
                                    return
                                }
                                print("Got data from facebook, Uploding.")
                                let fileName = chatUser.profilePictureFileName
                                StorageMamager.shared.uploadProfilePicture(with: data, fileName: fileName) { results in
                                    switch results{
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("storage Manager Error: \(error)")
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
            
            let credentials = FacebookAuthProvider.credential(withAccessToken: token)
            Auth.auth().signIn(with: credentials) { [weak self] authResult, err in
                
                guard let strongSelf = self else{
                    return
                }
                
                guard authResult != nil, err == nil else{
                    print("Facebook login credentials fail, MFA")
                    return
                }
                print("Successfully logged user in")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // Do nothing right now
        print("user has been logged out.")
    }
}
