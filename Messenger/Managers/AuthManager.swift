//
//  AuthManager.swift
//  Messenger
//
//  Created by Alena on 5/13/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit
import FirebaseAuth


typealias AuthManagerResultCallback = (_ user: User?, _ errorMessage: String?) -> Void


class AuthManager: NSObject {
    
    // MARK: - Shared Instance
    private var _user: User?
    var user: User? { get {return _user}}
    
    // MARK: - (De)Initialization
    private var handle: FIRAuthStateDidChangeListenerHandle!
    
    override init() {
        super.init()
        
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            
            print("addStateDidChangeListener, user = \(user)")
            if user == nil {
                
            }
        }
    }
    
    deinit {
        FIRAuth.auth()?.removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Public
    
    func loginUser(withEmail: String, password: String, completion: @escaping AuthManagerResultCallback) {
        
        let localCompletion = self.firebaseAuthResultCallback(withAuthManagerResultCallback: completion)
        
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: localCompletion)
    }
    
    
    func signupUser(withEmail: String, password: String, completion: @escaping AuthManagerResultCallback) {
        
        let localCompletion = self.firebaseAuthResultCallback(withAuthManagerResultCallback: completion)
        
        FIRAuth.auth()?.createUser(withEmail: withEmail, password: password, completion: localCompletion)
    }
    
    func logout() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let error as NSError {
            print("Firebase error signing out: %@", error)
        }
        _user = nil
    }
    
    // MARK: - Private
    private func firebaseAuthResultCallback(withAuthManagerResultCallback: @escaping AuthManagerResultCallback) -> FIRAuthResultCallback {
        
        return { (authUser, error) in
            
            print("user = \(authUser), error = \(error)")
            
            if error != nil || authUser == nil {
                
                var errorMessage: String? = error?.localizedDescription
                if errorMessage == nil {
                    errorMessage = "Server error occurred"
                }
                
                withAuthManagerResultCallback(nil, errorMessage)
                
            } else {
                
                self._user = User()
                self.user?.userId = authUser?.uid
                self.user?.email = authUser?.email
                self.user?.username = authUser?.email
                
                withAuthManagerResultCallback(self.user, nil)
                
            }
        }
    }
}
