//
//  Extensions.swift
//  Messenger
//
//  Created by Makwana Bhavin on 01/06/22.
//

import Foundation
import UIKit

extension UIView{
    public var width:CGFloat{
        return self.frame.size.width
    }
    
    public var height:CGFloat{
        return self.frame.size.height
    }
    
    public var top:CGFloat{
        return self.frame.origin.y
    }
    
    public var bottom:CGFloat{
        return self.frame.size.height + self.frame.origin.y
    }
    
    
    public var left:CGFloat{
        return self.frame.origin.x
    }
    
    public var right:CGFloat{
        return self.frame.size.width + self.frame.origin.x
    }
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



class CustomNavigationController: UINavigationController{
        
    func customBar(){
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

extension Notification.Name{
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
