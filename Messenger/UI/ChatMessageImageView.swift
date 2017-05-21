//
//  ChatMessageImageView.swift
//  Messenger
//
//  Created by Alena on 5/18/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit
import SDWebImage
import JSQMessagesViewController.JSQMessageMediaData


class ChatMessageImageView: NSObject, JSQMessageMediaData {
    
    private var mainView: UIView?
    private var imagePath: String?
    private var image: UIImage?
    private var bgColor: UIColor!
    private let size = CGSize(width:200, height: 200)
    
    override private init() {
        super.init()
    }
    
    public convenience init(withImagePath: String!, backgroundColor: UIColor!) {
        self.init()
        imagePath = withImagePath
        bgColor = backgroundColor
    }
    
    public convenience init(withImage: UIImage!, backgroundColor: UIColor!) {
        self.init()
        image = withImage
        bgColor = backgroundColor
    }
    
    @objc func mediaView() -> UIView! {
        if mainView == nil {
            mainView = UIView()
            mainView!.backgroundColor = bgColor
            let cornerRadius: CGFloat = 6
            mainView!.layer.cornerRadius = cornerRadius
            mainView!.clipsToBounds = true
            
            let imageView = UIImageView()
            imageView.frame = CGRect(origin:CGPoint(x: cornerRadius, y: cornerRadius), size: CGSize(width:size.width - cornerRadius * 2, height: size.height - cornerRadius * 2))
            imageView.backgroundColor = UIColor.white
            imageView.layer.cornerRadius = cornerRadius
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            let url = imagePath == nil ? nil : URL(string: imagePath!)
            let placeholder = url == nil ? image : UIImage(named: "msg_placeholder")
            imageView.sd_setImage(with: url, placeholderImage: placeholder)
            
            mainView!.addSubview(imageView)
            mainView!.frame = imageView.frame
        }
        return mainView!
    }
    
    @objc func mediaViewDisplaySize() -> CGSize {
        return size
    }
    
    
    @objc func mediaPlaceholderView() -> UIView! {
        return nil
    }
    
    @objc func mediaHash() -> UInt {
        return UInt(0)
    }
}
