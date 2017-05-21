//
//  UIViewController+Extensions.swift
//  Messenger
//
//  Created by Alena on 5/13/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit


extension UIViewController {
    
    // MARK: - Alerts
    func showAttentionAlert(message: String) {
        self.showOkAlert(title: "Attention", message: message)
    }
    
    func showErrorAlert(message: String) {
        self.showOkAlert(title: "Error", message: message)
    }
    
    func showOkAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    func navigationManager() -> NavigationManaging {
        return NavigationManager()
    }
    
    // MARK: - Activity indicator
    
    func showLoadingView(with text: String?) -> LoadingView! {
        let loadingView = LoadingView(view: self.view)
        loadingView.startLoading(text: text)
        
        return loadingView
    }
    
    func hideLoading(loadingView: LoadingView?) {
        if loadingView != nil {
            loadingView?.endLoading()
        }
    }
}
