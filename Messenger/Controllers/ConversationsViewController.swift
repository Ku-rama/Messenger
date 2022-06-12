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
import JGProgressHUD

struct Conversation{
    let id : String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage{
    let date: String
    let text: String
    let isRead: Bool
    
}

class ConversationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private let tableView: UITableView = {
        let table = UITableView()
//        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
        
        table.contentInset = UIEdgeInsets.zero
        return table
    }()
    
    private let noConverstionsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Converstions!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewMessage))
        if let token = AccessToken.current,
           !token.isExpired{
            // User is logged in, do work such as go to next view controller.
            print("User is loggged in with facebook")
        }
        validateAuth()
        setUpTableView()
        startListeningForConversation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        view.addSubview(noConverstionsLabel)
        view.addSubview(tableView)
        tableView.frame = view.bounds
//        noConverstionsLabel.center = view.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func validateAuth(){
        if Firebase.Auth.auth().currentUser == nil{
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    private func fetchConversations(){
        
    }
    
    private func startListeningForConversation(){
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] result in
            switch result{
                
            case .success(let conversations):
                print("got all the convos")
                
                guard !conversations.isEmpty else{
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Failed to get convos, \(error)")
            }
        }
    }
    
    @objc func createNewMessage(){
        
        let vc = NewConversationViewController()
        vc.completion = {[weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
            
        }
        let navVc = UINavigationController(rootViewController: vc)
        present(navVc, animated: true, completion: nil)
    }
    
    private func createNewConversation(result: [String: String]){
        
        guard let name = result["name"], let email = result["email"] else{
            print("Failed to get name and email of the User.")
            return
        }
        
        let vc = ChatViewController(with: email, id: "")
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ConversationsViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        print(model)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as? ConversationTableViewCell else{
            return UITableViewCell()
        }
        cell.configure(with: model)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = "Hello wrofl"
        return cell
        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}

