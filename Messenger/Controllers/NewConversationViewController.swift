//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 01/06/22.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var completion: (([String: String]) -> (Void))?
    private let spinner = JGProgressHUD()
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    
    private let searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for user..."
        searchBar.isUserInteractionEnabled = true
        return searchBar
    }()
    
    private let tableView : UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tv.isHidden = true
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
        view.backgroundColor = .systemBackground
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        view.addSubview(noResultsLabel)
        noResultsLabel.frame = CGRect(x: view.frame.midX-(150), y: view.frame.midY-15, width: 300, height: 30)
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    @objc func handleCancel(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        self.dismiss(animated: true, completion:{ [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        results.removeAll()
        spinner.show(in: view)
        self.searchUsers(query: searchText)
    }
    
    func searchUsers(query: String){
        // Check if app has firebase result
        if hasFetched{
            filterUsers(with: query)
        }
        // if not, fetch and the filter
        else{
            DatabaseManager.shared.getAllUsers { [weak self] result in
                guard let strongSelf = self else{
                    return
                }
                switch result{
                case .success(let usersCollection):
                    strongSelf.hasFetched = true
                    strongSelf.users = usersCollection
                    print(strongSelf.users)
                    strongSelf.filterUsers(with: query)
                case .failure(let err):
                    print("Failed to get users: \(err)")
                }
            }
        }
    }
    
    func filterUsers(with term: String){
        
        // Update the UI
        guard hasFetched else{
            return
        }
        
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() as? String else{
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        self.results = results
        updateUI()
    
    }
    
    func updateUI(){
        spinner.dismiss(animated: true)
        if self.results.isEmpty{
            self.noResultsLabel.isHidden = false
            self.tableView.isEditing = true
        }else{
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
