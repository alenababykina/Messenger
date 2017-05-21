//
//  User.swift
//  Messenger
//
//  Created by Alena on 5/13/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var userId: String!
    var email: String!
    var username: String!
    var imageData: String?
    
    private var image: UIImage?
    
    override init() {
        super.init()
        
    }
    
    override var description: String {
        return "User: id<\(userId)>, username<\(username)>, email<\(email)>"
    }
    
    func hasAvatar() -> Bool {
        return (imageData != nil)
    }
    
    func avatarImage() -> UIImage? {
        if image == nil && imageData != nil{
            let data = Data(base64Encoded: imageData!, options: .ignoreUnknownCharacters)!
            image = UIImage(data:data)
        }
        return image
    }
}
