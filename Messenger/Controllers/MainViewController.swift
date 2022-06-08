//
//  MainViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 02/06/22.
//

import UIKit

class MainViewController: CustomTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpViewController()
    }
    

}

extension MainViewController(){
    
}

class CustomTabBarController: UITabBarController{
    func customTabBar(){
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = tabBar.standardAppearance
        }
    }
}
