//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 01/06/22.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD()
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for user..."
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No results found!"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        label.textColor = .gray
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(handleCancel))
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = .blue
        searchBar.becomeFirstResponder()
    }
    
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        return cell
    }
    
     
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}
