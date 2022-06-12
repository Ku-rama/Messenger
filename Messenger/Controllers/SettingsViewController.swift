//
//  SettingsViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 02/06/22.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import MapKit

class SettingsViewController: UIViewController {
    
    let data = ["Log Out"]
    
    let tableView: UITableView = {
        let tv = UITableView()
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    func createTableHeader() -> UIView{
        
        let email = UserDefaults.standard.value(forKey: "email") as? String ?? ""
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail+"_profile_picture.png"
        let path = "images/"+fileName
        print(path)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .white
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = (imageView.width)/2
        headerView.addSubview(imageView)
        
        StorageMamager.shared.downloadUrl(for: path) { result in
            switch result{
            case .success(let url):
                self.downloadImage(imageView: imageView, url: url)
            case .failure(let err):
                print("Failed to get download url: \(err)")
            }
        }
        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL){
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else{
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textColor = .red
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath,
                              animated: true)
        
        let actionSheet = UIAlertController(title: "Really?",
                                            message: "Are you sure you want to Log out?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log out",
                                            style: .destructive,
                                            handler: {[weak self] _ in
            
            guard let strongSelf = self else{
                return
            }
            
            // Logout facebook
            FBSDKLoginKit.LoginManager().logOut()
            
            // Logout Google
            GIDSignIn.sharedInstance().signOut()
            
            do{
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: false)
            }catch{
                print("Failed to Log out.")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
}
