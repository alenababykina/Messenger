//
//  NavigationManager.swift
//  Messenger
//
//  Created by Alena on 5/13/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit


protocol NavigationManaging: class {
    func goToLoginView()
    func goToMainView()
}


class NavigationManager: NSObject, NavigationManaging {

    let StoryboardName = "Main"
    
    func goToLoginView() {
        self.goToView(withIdentifier: "LoginViewController");
    }
    
    func goToMainView() {
        self.goToView(withIdentifier: "MainViewController");
    }
    
    private func goToView(withIdentifier: String) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: self.StoryboardName, bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: withIdentifier)
        
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
}
