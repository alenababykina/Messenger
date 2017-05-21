//
//  LoginViewController.swift
//  Messenger
//
//  Created by Alena on 5/12/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpEmailTextField: UITextField!
    @IBOutlet weak var signUpUsernameTextField: UITextField!
    @IBOutlet weak var signUpPasswordTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var takeImageButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    private var authManager: AuthManager?
    private var dataManager: DataManager?

    private var username: String?
    private var image: UIImage?
    private var photoPicker: PhotoPicker?
    
    private var loadingView: LoadingView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        authManager = appDelegate.authManager
        
        self.goToLoginOnTap(nil)
    }

    
    // MARK: - Actions
    
    @IBAction func goToLoginOnTap(_ sender: UIButton?) {
        loginView.isHidden = false
        signUpView.isHidden = true
        self.view.backgroundColor = #colorLiteral(red: 0.7996829152, green: 0.894685328, blue: 0.9934437871, alpha: 1)
    }
    
    @IBAction func goToSignUpOnTap(_ sender: UIButton?) {
        loginView.isHidden = true
        signUpView.isHidden = false
        self.view.backgroundColor = #colorLiteral(red: 0.7339981198, green: 0.8725864291, blue: 0.9997665286, alpha: 1)
    }
    
    @IBAction func loginOnTap(_ sender: UIButton) {
        let email: String = emailTextField!.text!
        let pass: String = passTextField!.text!
        
        if self.validateInput(email: email, password: pass) {
            loadingView = self.showLoadingView(with: "Loading...")
            authManager?.loginUser(withEmail: email, password: pass, completion: self.loginSignUpCompletion(login: true))
        }
    }
    
    
    @IBAction func signUpOnTap(_ sender: UIButton) {
        let email: String = signUpEmailTextField!.text!
        let pass: String = signUpPasswordTextField!.text!
        
        if self.validateInput(email: email, password: pass) {
            
            let name: String = signUpUsernameTextField!.text!
            let minUsernameLength: Int = 6
            
            if name.characters.count < minUsernameLength {
                let message: String! = String.init(format: "Please enter Username with lenght at least %d characters", minUsernameLength)
                self.showAttentionAlert(message: message)
            } else {
                self.username = name
                loadingView = self.showLoadingView(with: "Loading...")
                authManager?.signupUser(withEmail: email, password: pass, completion: self.loginSignUpCompletion(login: false))
            }
        }
    }
    
    @IBAction func takeImageOnTap(_ sender: UIButton) {
        if image == nil {
            photoPicker = PhotoPicker(with: self)
            photoPicker?.openGallery(completion: { (image: UIImage?) in
                self.photoPicker = nil
                if image != nil {
                    self.image = image!.avatarAdjustedImageData()
                    self.avatarImageView.image = self.image
                    self.takeImageButton.setTitle("Remove", for: .normal)
                }
            })
        } else {
            self.image = nil
            self.avatarImageView.image = nil
            self.takeImageButton.setTitle("Take Image", for: .normal)
        }
    }
    
    // MARK: - Private
    
    private func loginSignUpCompletion(login: Bool) -> AuthManagerResultCallback {
        weak var weakSelf = self
        let result: AuthManagerResultCallback = { (user, errorMessage) in
            
            if weakSelf != nil {
                if errorMessage == nil {
                    // success -> perform inititalization of dataManager
                    
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    if appDelegate.initDataManager(withUser: user) {
                        weakSelf?.dataManager = appDelegate.dataManager
                        
                        let completion = { (error: NSError?) in
                            if error == nil {
                                weakSelf?.hideLoading(loadingView: weakSelf?.loadingView)
                                weakSelf?.navigationManager().goToMainView()
                            } else {
                                weakSelf?.showErrorAlert(message: "Sorry, Internal error occurred.")
                                weakSelf?.hideLoading(loadingView: weakSelf?.loadingView)
                            }
                        }
                        
                        if login {
                            weakSelf?.dataManager?.getCurrentUserProfile(completion: completion)
                        } else {
                            // registration
                            weakSelf?.dataManager?.addCurrentUserProfile(displayName: weakSelf?.username!, image: weakSelf?.image, completion: completion)
                        }
                        
                    } else {
                        weakSelf?.showErrorAlert(message: "Sorry, Internal error occurred.")
                        weakSelf?.hideLoading(loadingView: weakSelf?.loadingView)
                    }

                } else {
                    weakSelf?.showErrorAlert(message: errorMessage!)
                    weakSelf?.hideLoading(loadingView: weakSelf?.loadingView)
                }
            }
        }
        
        return result
    }
    
    private func validateInput(email: String, password: String) -> Bool {
        
        let minPassLength: Int = 6
        
        if email.characters.isEmpty || password.characters.isEmpty {
            self.showAttentionAlert(message: "Email and Password are required")
        } else {
            if !email.isValidEmail() {
                self.showAttentionAlert(message: "Please enter valid Email address")
            } else {
                if password.characters.count < minPassLength {
                    let message: String! = String.init(format: "Minimum Password lenght is %d", minPassLength)
                    self.showAttentionAlert(message: message)
                } else {
                    return true
                }
            }
        }
        
        return false
    }
    

    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            passTextField.becomeFirstResponder()
        } else if textField == passTextField {
            loginOnTap(loginButton)
        } else if textField == signUpEmailTextField {
            signUpPasswordTextField.becomeFirstResponder()
        } else if textField == signUpPasswordTextField {
            signUpUsernameTextField.becomeFirstResponder()
        } else if textField == signUpUsernameTextField {
            signUpUsernameTextField.resignFirstResponder()
        }
        
        return true;
    }
}

