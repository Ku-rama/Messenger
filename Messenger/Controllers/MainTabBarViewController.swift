//
//  MainViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 02/06/22.
//

import UIKit
import Firebase

class MainTabBarViewController: CustomTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpViewController()
    }
    
    
    
}

extension MainTabBarViewController{
    func setUpViewController(){
        
        let converstionController = ConversationsViewController()
        converstionController.title = "iMessages"
        let conNavController = CustomNavigationController(rootViewController: converstionController)
        conNavController.navigationBar.prefersLargeTitles = true
        conNavController.title = "Chats"
        conNavController.customBar()
        
        let settingsController = SettingsViewController()
//        homeController.title = "Home"
        let settingsNavController = CustomNavigationController(rootViewController: settingsController)
        settingsNavController.title = "Profile"
        settingsNavController.customBar()
        
        self.setViewControllers([conNavController, settingsNavController], animated: true)
        self.modalPresentationStyle = .fullScreen
        self.customTabBar()
        tabBar.tintColor = .white
        
        setUpTabBarIcon(viewController: conNavController, normalImage: "text.bubble", selectedImage: "text.bubble.fill")
        setUpTabBarIcon(viewController: settingsNavController, normalImage: "gearshape", selectedImage: "gearshape.fill")
    }
    
    public func setUpTabBarIcon(viewController: CustomNavigationController, normalImage: String, selectedImage: String){
        viewController.tabBarItem.image?.withTintColor(.white)
        viewController.tabBarItem.image = UIImage(systemName: normalImage)
        viewController.tabBarItem.selectedImage = UIImage(systemName: selectedImage)
        
    }
}

