//
//  DataManager.swift
//  Messenger
//
//  Created by Alena on 5/14/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage


enum DataManagerError: Error {
    case InitError(String)
}


class DataManager: NSObject {

    static let KeyUsers = "Users"
    static let KeyUsername = "Username"
    static let KeyEmail = "Email"
    static let KeyImage = "Image"
    
    static let KeyUsersChats = "UsersChats"
    static let KeyLastMessage = "LastMessage"
    static let KeyParticipants = "Participants"
    static let KeyStatus = "Status"
    
    static let KeyChatMessages = "ChatMessages"
    static let KeySenderId = "SenderId"
    static let KeyText = "Text"
    static let KeyImageUrl = "ImageUrl"
    static let KeyTime = "Time"
    
    static let PathProfileImage = "Image/Profile"
    static let PathMessageImage = "Image/Message"
    
    var user: User!
    private var database: FIRDatabaseReference!
    private var storage: FIRStorageReference!
    private var observeHandlers: [String : String] = [:]
    
    override private init() {
        super.init()
    }
    
    
    /** @brief initializator init withUser
     @param withUser - cannot be nil, with valid uid, and email.
     @remarks Throws error if 'withUser' is nil or uid and/or email isEmpty.
     */
    public convenience init(withUser: User!) throws {
        self.init()
        
        var errorMessage: String?
        
        if withUser == nil {
            errorMessage = "User cannot be nil"
        } else if withUser?.userId == nil || withUser?.userId?.isEmpty == true {
            errorMessage = "UserId cannot be empty"
        } else if withUser?.email == nil || withUser?.email?.isEmpty == true {
            errorMessage = "User email cannot be empty"
        }
        
        if errorMessage != nil {
            throw DataManagerError.InitError(errorMessage!)
        } else {
            user = withUser
            database = FIRDatabase.database().reference()
            storage = FIRStorage.storage().reference()
        }
    }
    
    deinit {
        for key in observeHandlers.keys {
            let handler = UInt(key)!
            let path = observeHandlers[key]!
            database.child(path).removeObserver(withHandle: handler)
        }
        database.removeAllObservers()
    }
    
    // MARK: - Users
    
    func getCurrentUserProfile(completion: ((_ error: NSError?) -> Void)?) {
        weak var weakSelf = self
        database.child(DataManager.KeyUsers).child(user.userId).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            let value = snapshot.value as? NSDictionary
            if value == nil{
                completion?(NSError(domain: "Custom Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error getting user profile"]))
            } else {
                weakSelf?.user.username = value![DataManager.KeyUsername] as! String
                weakSelf?.user.imageData = value![DataManager.KeyImage] as? String
                completion?(nil)
            }
        }){ (error) in
            print("Observe user error: %@", error.localizedDescription)
            completion?(error as NSError)
        }
    }
    
    func addCurrentUserProfile(displayName: String!, image: UIImage?, completion: ((_ error: NSError?) -> Void)?) {
        weak var weakSelf = self
        database.child(DataManager.KeyUsers).child(user.userId).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            
            let value = snapshot.value as? NSDictionary
            
            if value == nil{
                var userData: [String: String] = [
                    DataManager.KeyEmail: weakSelf!.user.email!,
                    DataManager.KeyUsername: displayName
                ]
                
                weakSelf?.user.username = displayName
                
                if image != nil {
                    let imageData = UIImageJPEGRepresentation(image!, 0.8)!
                    let base64String: String = imageData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
                    userData[DataManager.KeyImage] = base64String
                    
                    weakSelf?.user.imageData = base64String
                }
                
            weakSelf!.database.child(DataManager.KeyUsers).child(weakSelf!.user.userId!).setValue(userData)
            completion?(nil)
            }
        }){ (error) in
            print("Observe user error: %@", error.localizedDescription)
            completion?(error as NSError)
        }
    }
    
    func removeObserver(handler: UInt) {
        let key = String(handler)
        let path: String? = observeHandlers[key]
        if path != nil {
            database.child(path!).removeObserver(withHandle: handler)
            observeHandlers[key] = nil
            print("DataManager - remove observer: \(key)")
        }
    }
    
    func observeUsers(completion: @escaping (_ users: Array<User>?, _ error: NSError?) -> Void) -> UInt! {
        let path = "\(DataManager.KeyUsers)"
        let observerHandler = database.child(path).observe(.value, with:
        { (snapshot: FIRDataSnapshot) in
            
            let value = snapshot.value as? NSDictionary
            if value != nil {
                var usersArray: Array<User> = []
                
                for key in (value?.allKeys)! {
                    let tmpUser = User()
                    
                    tmpUser.userId = key as! String
                    
                    let userData = value?[key] as! NSDictionary
                    tmpUser.email = userData[DataManager.KeyEmail] as? String
                    tmpUser.username = userData[DataManager.KeyUsername] as? String
                    tmpUser.imageData = userData[DataManager.KeyImage] as? String
                    
                    usersArray.append(tmpUser)
                }
                
                completion(usersArray, nil)
                print("=== Users changed")
            }
        })
        observeHandlers[String(observerHandler)] = path
        return observerHandler
    }
    
    // MARK: - Chats
    func observeChats(completion: @escaping (_ users: Array<Chat>?, _ error: NSError?) -> Void) -> UInt! {
        let path = "\(DataManager.KeyUsersChats)/\(user.userId!)"
        let observerHandler = database.child(path).observe(.value, with:
            { (snapshot: FIRDataSnapshot) in
                
                let value = snapshot.value as? [String : Any]
                if value != nil {
                
                    var chatsArray: Array<Chat> = []
                    
                    for key in value!.keys {
                        let tmpChat = Chat()
                        
                        tmpChat.chatId = key
                        
                        let chatData = value![key] as! [String: Any]
                        tmpChat.lastMessage = chatData[DataManager.KeyLastMessage] as! String
                        tmpChat.lastMessageTime = chatData[DataManager.KeyTime] as! UInt
                        let participants = chatData[DataManager.KeyParticipants] as? [String : Any]
                        if participants != nil {
                            var participntsIds: [String] = []
                            for key in participants!.keys {
                                participntsIds.append(key)
                            }
                            tmpChat.participants = participntsIds
                        }
                        let status = chatData[DataManager.KeyStatus] as? String
                        if status != nil {
                            tmpChat.status = ChatStatus(rawValue: status!)
                        }
                        
                        chatsArray.append(tmpChat)
                    }
                    chatsArray.sort{ (first, second) -> Bool in
                        return first.lastMessageTime > second.lastMessageTime}
                    completion(chatsArray, nil)
                    print("=== Chats of current user changed")
                }
        })
        
        observeHandlers[String(observerHandler)] = path
        return observerHandler
    }
    
    func createChat(participants: Array<User>!, message: String!, completion: ((_ chatId: String?, _ error: NSError?) -> Void)?) {
        createChat(participants: participants, message: message, image: nil, completion: completion)
    }
    
    func createChat(participants: Array<User>!, image: UIImage!, completion: ((_ chatId: String?, _ error: NSError?) -> Void)?) {
        createChat(participants: participants, message: nil, image: image, completion: completion)
    }
    
    private func createChat(participants: Array<User>!, message: String?, image: UIImage?, completion: ((_ chatId: String?, _ error: NSError?) -> Void)?) {
        
        let chatId = database.child(DataManager.KeyUsersChats).child(user.userId).childByAutoId().key
        let messageId = database.child(DataManager.KeyChatMessages).child(chatId).childByAutoId().key
        
        if image != nil {
            let imagePath = "\(DataManager.PathMessageImage)/\(messageId).jpg"
            weak var weakSelf = self
            upload(image: image!, path: imagePath, completion: { (downloadPath, error) in
                if error != nil {
                    completion?(nil, error)
                } else {
                    weakSelf?.createChat(chatId: chatId, messageId: messageId, participants: participants, key: DataManager.KeyImageUrl, value: downloadPath!, completion: completion)
                }
            })
        } else if message != nil {
            createChat(chatId: chatId, messageId: messageId, participants: participants, key: DataManager.KeyText, value: message!, completion: completion)
        } else {
            print("Error: nothing to send, image & message = nil")
        }
    }
    
    private func createChat(chatId: String!, messageId: String!, participants: Array<User>!, key: String!, value: String!, completion: ((_ chatId: String?, _ error: NSError?) -> Void)?) {
        
        var childUpdates: [String : Any] = [:]
        
        var participantsIds: [String : Any] = [:]
        for user in participants {
            participantsIds[user.userId] = (true)
        }
        
        for participantId in participantsIds.keys {
            let userId = participantId as String!
            let childPath = "/\(DataManager.KeyUsersChats)/\(userId!)/\(chatId!)/\(DataManager.KeyLastMessage)"
            childUpdates[childPath] = (key != DataManager.KeyImageUrl) ? value : "<image>"
            
            childUpdates["/\(DataManager.KeyUsersChats)/\(userId!)/\(chatId!)/\(DataManager.KeyTime)"] = FIRServerValue.timestamp()
            
            childUpdates["/\(DataManager.KeyUsersChats)/\(userId!)/\(chatId!)/\(DataManager.KeyParticipants)"] = participantsIds
            
            childUpdates["/\(DataManager.KeyUsersChats)/\(userId!)/\(chatId!)/\(DataManager.KeyStatus)"] = (userId == self.user.userId) ? ChatStatus.accepted.rawValue : ChatStatus.new.rawValue
        }
        
        let message = [DataManager.KeySenderId: self.user.userId,
                         key: value,
                         DataManager.KeyTime: FIRServerValue.timestamp()] as [String : Any]
        
        
        childUpdates["/\(DataManager.KeyChatMessages)/\(chatId!)/\(messageId!)"] = message
        
        database.updateChildValues(childUpdates)
        
        completion?(chatId, nil)
    }
    
    func updateChatStatus(chatId: String!, status: ChatStatus!, completion: ((_ error: NSError?) -> Void)?) {
        let path = "\(DataManager.KeyUsersChats)/\(user.userId!)/\(chatId!)/\(DataManager.KeyStatus)"
        
        let childUpdates: [String : Any] = [path : status.rawValue]
        database.updateChildValues(childUpdates)
        
        completion?(nil)
    }
    
    // MARK: - Messages
    func observeChatMessages(chatId: String!, initialCompletion: @escaping (_ messages: [Any]?) -> Void, additionalCompletion: @escaping (_ message: Any?) -> Void) -> UInt! {
        
        var initialDataReceived = false
        
        database.child(DataManager.KeyChatMessages).child(chatId).observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            
            let messagesData = snapshot.value as? [String : Any]
            if messagesData != nil {
                initialDataReceived = true
                var messagesArray = Array(messagesData!.values) as! Array<[String : Any]>
                messagesArray.sort{ (first, second) -> Bool in
                    return (first[DataManager.KeyTime] as! UInt) < (second[DataManager.KeyTime] as! UInt)}
                initialCompletion(messagesArray)
                print("=== Chat messages received")
            }
        })
        
        let path = "\(DataManager.KeyChatMessages)/\(chatId!)"
        let observerHandler = database.child(path).observe(.childAdded, with:
            { (snapshot: FIRDataSnapshot) in
                if initialDataReceived == false {
                    return
                } else {
                    let message = snapshot.value as? [String: Any]
                    if message != nil {
                        additionalCompletion(message)
                        print("=== New message received")
                    }
                }
        })
        observeHandlers[String(observerHandler)] = path
        return observerHandler
    }

    func sendMessage(chatId: String!, image: UIImage!, completion: ((_ error: NSError?) -> Void)?) {
        sendMessage(chatId: chatId, text: nil, image: image, completion: completion)
    }
    func sendMessage(chatId: String!, text: String!, completion: ((_ error: NSError?) -> Void)?) {
        sendMessage(chatId: chatId, text: text, image: nil, completion: completion)
    }
    
    private func sendMessage(chatId: String!, text: String?, image: UIImage?, completion: ((_ error: NSError?) -> Void)?) {
        
        let messageId = self.database.child(DataManager.KeyChatMessages).child(chatId).childByAutoId().key
        
        if image != nil {
            let imagePath = "\(DataManager.PathMessageImage)/\(messageId).jpg"
            weak var weakSelf = self
            upload(image: image!, path: imagePath, completion: { (downloadPath, error) in
                if error != nil {
                    completion?(error)
                } else {
                    weakSelf?.sendMessage(chatId: chatId, key: DataManager.KeyImageUrl, value: downloadPath!, messageId: messageId, completion: completion)
                }
            })
        } else if text != nil {
            sendMessage(chatId: chatId, key: DataManager.KeyText, value: text!, messageId: messageId, completion: completion)
        } else {
            print("Error: nothing to send, image & text = nil")
        }
    }
    
    private func sendMessage(chatId: String!, key: String!, value: String!, messageId: String!, completion: ((_ error: NSError?) -> Void)?) {
    
        let path = "\(DataManager.KeyUsersChats)/\(user.userId!)/\(chatId!)/\(DataManager.KeyParticipants)"
        database.child(path).observeSingleEvent(of: .value, with:
            { (snapshot: FIRDataSnapshot) in
                    let participants = snapshot.value as? [String : Any]
                    if participants != nil {
                    
                    var childUpdates: [String : Any] = [:]
                    
                    for participantId in participants!.keys {
                        let userId = participantId as String!
                        let childPath = "/\(DataManager.KeyUsersChats)/\(userId!)/\(chatId!)/\(DataManager.KeyLastMessage)"
                        childUpdates[childPath] = (key != DataManager.KeyImageUrl) ? value : "<image>"
                        childUpdates["/\(DataManager.KeyUsersChats)/\(userId!)/\(chatId!)/\(DataManager.KeyTime)"] = FIRServerValue.timestamp()
                    }
                    
                    
                    let message = [DataManager.KeySenderId: self.user.userId!,
                                   key: value,
                                   DataManager.KeyTime: FIRServerValue.timestamp()] as [String : Any]
                    
                    
                    childUpdates["/\(DataManager.KeyChatMessages)/\(chatId!)/\(messageId)"] = message
                    
                    self.database.updateChildValues(childUpdates)
                    completion?(nil)
                }
                
            })
    }
    
    private func upload(image: UIImage!, path: String!, completion: ((_ downloadPath: String?, _ error: NSError?) -> Void)?) {
        
        let imageData = UIImageJPEGRepresentation(image, 0.8)
        storage.child(path).put(imageData!, metadata: nil, completion:
            { (metadata, error) in
                var path: String?
                if error != nil {
                    completion?(nil, error as? NSError)
                } else if metadata != nil{
                    
                    let downloadUrl = metadata!.downloadURL()
                    print("Upload image successful: \(downloadUrl!)")
                    
                    if downloadUrl != nil {
                        path = downloadUrl!.absoluteString
                    }
                }
                
                if path != nil {
                    completion?(path!, nil)
                } else {
                    completion?(nil, NSError(domain: "Custom Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error of image uploading"]))
                }
        })
    }
}
