//
//  AppDelegate.swift
//  Messenger
//
//  Created by Alena on 5/12/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var authManager: AuthManager! = AuthManager()
    var dataManager: DataManager!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FIRApp.configure()
        self.applyNavBarAppearance()
        
        return true
    }
    
    func initDataManager(withUser: User?) -> Bool {
        do {
            try dataManager = DataManager(withUser: withUser)
        } catch let error {
            print("Create DataManager error: \(error); user: \(withUser)")
            return false
        }
        
        return true;
    }
    
    func deinitDataManager() {
        dataManager = nil
    }

    private func applyNavBarAppearance() {
        let navigationBarAppearace = UINavigationBar.appearance()
        
        navigationBarAppearace.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        navigationBarAppearace.barTintColor = #colorLiteral(red: 0, green: 0.3647058824, blue: 0.6392156863, alpha: 1)
        navigationBarAppearace.titleTextAttributes = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 17), NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

