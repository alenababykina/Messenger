//
//  Chat.swift
//  Messenger
//
//  Created by Alena on 5/15/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit

enum ChatStatus: String {
    case new = "new", accepted = "accepted", declined = "declined"
}

class Chat: NSObject {
    
    var chatId: String! = ""
    var participants: Array<String>?
    var lastMessage: String! = ""
    var lastMessageTime: UInt! = 0
    var status: ChatStatus! = .new
    
    private var _chatName: String?
    
    override init() {
        super.init()
    }
    
    override var description: String {
        return "Chat: id<\(chatId)>, lastMessage<\(lastMessage)>"
    }
    
    func chatName(with users: Array<User>?, currentUser: User?) -> String {
        if _chatName != nil {
            return _chatName!
        }
        
        
        if participants != nil && users != nil && currentUser != nil {
            var chatName: String = ""
            
            if participants!.count == 1 {
                
                let participant = participants![0]
                if participant == currentUser!.userId {
                    chatName = "myself :)"
                } else {
                    let tmpUser = self.findUser(with: participant, at: users)
                    if tmpUser != nil {
                        chatName = tmpUser!.username
                    }
                }
                
            } else if participants!.count > 1 {
            
                for participant in participants! {
                    
                    if participant != currentUser?.userId {
                        let tmpUser = self.findUser(with: participant, at: users)
                        if tmpUser != nil {
                            if chatName.isEmpty == false {
                                chatName.append(", ")
                            }
                            chatName.append(tmpUser!.username)
                        }
                    }
                }
            }
            
            if chatName.isEmpty == false {
                _chatName = "Chat with: " + chatName
                return _chatName!
            }
            
        }
        
        return "Unknown"
    }
    
    private func findUser(with userId: String!, at users: Array<User>!) -> User? {
        
        for user in users {
            if user.userId == userId {
                return user
            }
        }
        
        return nil
    }
}
