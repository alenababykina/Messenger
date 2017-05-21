//
//  ContactsViewController.swift
//  Messenger
//
//  Created by Alena on 5/13/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit


class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private var authManager: AuthManager!
    private var dataManager: DataManager!
    
    private var tableDataArray: Array<Any>?
    private var usersArray: Array<User>?
    private var chatsArray: Array<Chat>?
    
    private let ChatsTabIndex = 0
    private let ContactsTabIndex = 1
    
    private var handlers: Array<UInt> = []
    private var longTapRecognizer: UILongPressGestureRecognizer?
    private var multipleUsersSelect = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        authManager = appDelegate.authManager
        dataManager = appDelegate.dataManager
        
        segmentedControl.setTitleTextAttributes([NSFontAttributeName : UIFont.systemFont(ofSize: 18)], for: .normal)
        segmentChanged(segmentedControl)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weak var weakSelf = self
        
        var handler: UInt! = dataManager.observeUsers(completion: { (users, error) in
            weakSelf?.usersArray = users
            
            if weakSelf?.segmentedControl.selectedSegmentIndex == self.ContactsTabIndex {
                weakSelf?.tableDataArray = users
            }
            
            weakSelf?.tableView.reloadData()
        })
        
        handlers.append(handler)
        
        handler = dataManager.observeChats(completion: { (chats, error) in
            weakSelf?.chatsArray = chats
            
            if weakSelf?.segmentedControl.selectedSegmentIndex == self.ChatsTabIndex {
                weakSelf?.tableDataArray = chats
                weakSelf?.tableView.reloadData()
            }
        })
        handlers.append(handler)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        for handler in handlers {
            dataManager.removeObserver(handler: handler)
        }
        handlers = []
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private
    private func addLongTapGestureRecognizer() {
        if longTapRecognizer == nil {
            longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longTap(_:)))
            longTapRecognizer!.minimumPressDuration = 0.8 
            tableView.addGestureRecognizer(longTapRecognizer!)
        }
    }
    
    @objc private func longTap(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.ended {
            
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                multipleUsersSelect = true
                tableView.allowsMultipleSelection = true
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                
                let barButton = UIBarButtonItem(title: "Create chat", style: .done, target: self, action: #selector(self.createChat))
                
                self.navigationItem.rightBarButtonItem = barButton
            }
        }
    }
    
    private func deactivateMultipleUserSelect () {
        if multipleUsersSelect == true {
            let selectedItems = tableView.indexPathsForSelectedRows
            if selectedItems != nil {
                for indexPath in selectedItems! {
                    tableView.deselectRow(at: indexPath, animated: false)
                }
            }
            self.navigationItem.rightBarButtonItem = nil
            tableView.allowsMultipleSelection = false
            multipleUsersSelect = false
        }
    }
    
    private func removeLongTapGestureRecognizer() {
        if longTapRecognizer != nil {
            tableView.removeGestureRecognizer(longTapRecognizer!)
            longTapRecognizer = nil
        }
    }
    
    @objc private func createChat() {
        let selectedItems = tableView.indexPathsForSelectedRows
        if selectedItems != nil && selectedItems!.count > 0 {
            var participants: Array<User> = []
            for indexPath in selectedItems! {
                let user = tableDataArray![indexPath.row] as! User
                participants.append(user)
            }
            
            self.performSegue(withIdentifier: SegueIdToChatView, sender: participants)
            deactivateMultipleUserSelect()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let chatViewController = segue.destination as! ChatViewController
        
        chatViewController.currentUser = dataManager.user
        
        var participants: Array<User>! = []
        
        let currentUser = dataManager.user
        if currentUser != nil {
            participants.append(currentUser!)
        }

        if sender != nil {
            if sender is Chat {
                let chat = sender as! Chat
                chatViewController.chat = chat
                let participantIds = chat.participants
                if participantIds != nil && usersArray != nil {
                    for user in usersArray! {
                        if user.userId != currentUser?.userId && participantIds!.contains(user.userId) {
                            participants.append(user)
                            if participants.count == participantIds!.count {
                                break
                            }
                        }
                    }
                }
                
            } else if sender is User {
                let tmpUser = sender as! User
                if tmpUser.userId != currentUser?.userId {
                    participants.append(tmpUser)
                }
            
            } else {
                let users = sender as? Array<User>
                if users != nil {
                    for tmpUser in users! {
                        if tmpUser.userId != currentUser?.userId {
                            participants.append(tmpUser)
                        }
                    }
                }
            }
        }
        
        chatViewController.participants = participants
    }
    
    // MARK: - Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == ChatsTabIndex {
            // chats
            self.title = "\(dataManager.user.username!)\'s Chats"
            self.tableDataArray = chatsArray
            removeLongTapGestureRecognizer()
            deactivateMultipleUserSelect()
        } else {
            // contacts
            self.title = "\(dataManager.user.username!)\'s Contacts"
            self.tableDataArray = usersArray
            addLongTapGestureRecognizer()
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func logOutOnTap(_ sender: UIBarButtonItem) {
        
        authManager.logout()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.deinitDataManager()
        
        self.navigationManager().goToLoginView()
    }
    

    // MARK: - UITableView dataSource & delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataArray != nil ? (tableDataArray?.count)! : 0
    }
    
    let CellIdentifier = "ContactsCell"
    let dafultAvatarImage = UIImage(named:"avatar")
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath)
        
        if self.segmentedControl.selectedSegmentIndex == self.ChatsTabIndex {
            let chat: Chat = tableDataArray![indexPath.row] as! Chat
            
            cell.textLabel?.text = chat.chatName(with: self.usersArray, currentUser: dataManager.user)
            cell.detailTextLabel?.text = chat.lastMessage
            let icon = chat.status == .new ? UIImage(named: "new_icon") : nil
            cell.imageView?.image = icon
        } else {
            let user: User = tableDataArray![indexPath.row] as! User
            cell.textLabel?.text = user.username
            cell.imageView?.layer.cornerRadius = 8
            cell.imageView?.clipsToBounds = true
            cell.imageView?.image = user.hasAvatar() ? user.avatarImage() : dafultAvatarImage
            cell.detailTextLabel?.text = nil
        }
        
        return cell
    }
    
    let SegueIdToChatView = "GoToChatView"
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sender = tableDataArray![indexPath.row]
        if multipleUsersSelect == false {
            self.performSegue(withIdentifier: SegueIdToChatView, sender: sender)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if multipleUsersSelect == true {
            let selectedItems = tableView.indexPathsForSelectedRows
            if selectedItems == nil || selectedItems!.count == 0 {
                deactivateMultipleUserSelect()
            }
        }
    }
}
