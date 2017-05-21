//
//  ChatViewController.swift
//  Messenger
//
//  Created by Alena on 5/15/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class ChatViewController: JSQMessagesViewController {

    @IBOutlet var invitationView: UIView!
    @IBOutlet weak var invitationLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    private var loadingView: LoadingView?
    
    var participants: Array <User>!
    var currentUser: User!
    var chat: Chat?
    private var userImages: [String: UIImage] = [:]
    private var userNames: [String: String] = [:]
    
    private var photoPicker: PhotoPicker?
    private var dataManager: DataManager!
    private var handlers: Array<UInt> = []
    
    private let OutcomingColor = #colorLiteral(red: 0, green: 0.5028136969, blue: 0.9942864776, alpha: 1)
    private let IncomingColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
    
    private var tableViewData = [JSQMessage]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataManager = appDelegate.dataManager
        
        self.senderId = currentUser.userId
        self.senderDisplayName = currentUser.username
        
        if chat != nil {
            self.requestChatMessages(chatId: chat!.chatId)
        }
        self.updateInvitationView(animated: false)
        
        self.collectionView.backgroundColor = #colorLiteral(red: 0.9380475879, green: 0.9630405307, blue: 1, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    private func updateInvitationView (animated: Bool) {
        var hide = true
        if chat != nil {
            
            let status = chat!.status
            if status != .accepted {
                hide = false
                invitationView.isHidden = false
                let viewHeight: CGFloat = 100
                invitationView.frame = CGRect(origin:CGPoint(x: 0, y: 0),size: CGSize(width: view.bounds.size.width, height: viewHeight))
                invitationView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(invitationView)
                let constraints = [
                    NSLayoutConstraint(item: invitationView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: invitationView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0),
                    NSLayoutConstraint(item: invitationView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)]
                self.view.addConstraints(constraints)
                invitationView.addConstraint(NSLayoutConstraint(item: invitationView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: viewHeight))
                view.bringSubview(toFront: invitationView)
                
                if status == .new {
                    invitationLabel.text = "This is a new chat. Would you like to accept an invitation?"
                    acceptButton.isEnabled = true
                    declineButton.isEnabled = true
                } else {
                    invitationLabel.text = "Previously you have declined invitation. Would you like to change your decision?"
                    acceptButton.isEnabled = true
                    declineButton.isEnabled = false
                }
                
            }
        }

        if hide == true {
            UIView.animate(withDuration: 0.3, animations: {
                self.invitationView.alpha = 0
            }, completion: { (b) in
                self.invitationView.isHidden = true
            })
        }
    }
    
    private func avatarImage(for userId: String!) -> UIImage! {
        var image = userImages[userId]
        if image == nil {
            for user in participants {
                if user.userId == userId && user.hasAvatar() {
                    image = user.avatarImage()
                    break
                }
            }
            if image == nil {
                image = UIImage(named:"avatar")
            }
            userImages[userId] = image
        }
        return image
    }
    
    private func senderName(for message: JSQMessage!) -> String! {
        var name = userNames[message.senderId]
        if name == nil {
            for user in participants {
                if user.userId == message.senderId {
                    name = user.username
                    userNames[message.senderId] = name
                    break
                }
            }
        }
        return name
    }
    
    private func requestChatMessages(chatId: String!) {
        weak var weakSelf = self
        loadingView = self.showLoadingView(with: "Loading...")
        let handler: UInt! = dataManager.observeChatMessages(chatId: chatId, initialCompletion: { (array) in
            weakSelf?.applyChatMessages(messages: array)
            weakSelf?.hideLoading(loadingView: weakSelf?.loadingView)
        }, additionalCompletion: { (messageData) in
            if weakSelf != nil {
                let message = weakSelf?.jsqMessage(from: messageData)
                if message != nil {
                    if (message?.senderId != weakSelf?.currentUser.userId) {
                        weakSelf?.append(message: message)
                    }
                }
            }
        })
        handlers.append(handler)
    }
    
    private func append(message: JSQMessage!) {
        
        tableViewData.append(message)
        let currentMessagesCount = tableViewData.count
        let index = IndexPath(row: currentMessagesCount - 1, section:0)
        collectionView.insertItems(at: [index])
        collectionView.scrollToItem(at: index, at: .bottom, animated: true)
    }

    private func applyChatMessages(messages:Array<Any>?) {
        if messages != nil {
            tableViewData = []
            for item in messages! {
                let message = self.jsqMessage(from: item)
                if message != nil {
                    tableViewData.append(message!)
                }
            }
            self.collectionView.reloadData()
            if chat?.status == .accepted {
                let index = IndexPath(row: tableViewData.count - 1, section:0)
                collectionView.scrollToItem(at: index, at: .bottom, animated: false)
            }
            print("reload")
        }
    }
    
    private func jsqMessage(from data:Any?) -> JSQMessage? {
        if data != nil {
            let messageData = data as? [String: Any]
            if messageData != nil {
                let senderId = messageData!["SenderId"] as! String
                let imagePath = messageData!["ImageUrl"] as? String
                if imagePath != nil {
                    let media: JSQMessageMediaData! = ChatMessageImageView(withImagePath: imagePath!, backgroundColor: senderId == currentUser.userId ? OutcomingColor : IncomingColor)
                    return JSQMessage(senderId: senderId,
                                      displayName: "",
                                      media: media)
                } else {
                
                return JSQMessage(senderId: senderId,
                                  displayName: "",
                                  text: messageData!["Text"] as! String)
                }
            }
        }
        return nil
    }
    
    private func jsqMessage(text: String?, image: UIImage?) -> JSQMessage? {
        if image != nil {
            let media: JSQMessageMediaData! = ChatMessageImageView(withImage: image!, backgroundColor: OutcomingColor)
            return JSQMessage(senderId: currentUser.userId, displayName: "", media: media)
        } else if text != nil {
            return JSQMessage(senderId: currentUser.userId, displayName: "", text: text)
        }
        return nil
    }
    
    private func updateChatStaus(_ status: ChatStatus!) {
        if chat != nil {
            chat!.status = status
            dataManager.updateChatStatus(chatId: chat!.chatId, status: status, completion: nil)
            self.updateInvitationView(animated: true)
        }
    }
    
    // MARK: - Actions
    @IBAction func acceptOnTap(_ sender: UIButton) {
        self.updateChatStaus(.accepted)
    }
    
    @IBAction func declineOnTap(_ sender: Any) {
        self.updateChatStaus(.declined)
    }
    
    // MARK: - JSQ
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        send(message: text, or: nil)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        photoPicker = PhotoPicker(with: self)
        photoPicker?.openGallery(completion: { (image: UIImage?) in
            self.photoPicker = nil
            if image != nil {
                self.send(message: nil, or: image)
            }
        })
    }
    
    private func send(message: String?, or image: UIImage?) {
        
        loadingView = self.showLoadingView(with: "Sending...")
        weak var weakSelf = self
        if chat != nil {
            let completion = { (error: NSError?) in
                weakSelf?.hideLoading(loadingView: weakSelf?.loadingView)
                if error != nil {
                    weakSelf?.showErrorAlert(message: "Sorry! Error of message/image sending.")
                } else {
                    
                    let jsqMessage = weakSelf?.jsqMessage(text: message, image: image)
                    if jsqMessage != nil {
                        weakSelf?.append(message: jsqMessage)
                    }
                    weakSelf?.finishSendingMessage()
                }
            }
            if image != nil {
                dataManager.sendMessage(chatId: weakSelf?.chat!.chatId, image: image, completion: completion)
            } else {
                dataManager.sendMessage(chatId: chat!.chatId, text: message, completion: completion)
            }
        } else {
            let completion = { (chatId: String?, error: NSError?) in
                weakSelf?.hideLoading(loadingView: weakSelf?.loadingView)
                if error != nil || chatId == nil {
                    weakSelf?.showErrorAlert(message: "Sorry! Error of chat creating.")
                } else {
                    weakSelf?.chat = Chat()
                    weakSelf?.chat?.chatId = chatId!
                    weakSelf?.chat?.status = .accepted
                    weakSelf?.requestChatMessages(chatId: chatId!)
                    weakSelf?.finishSendingMessage()
                }
            }
            
            if image != nil {
                dataManager.createChat(participants: participants, image: image!, completion: completion)
            } else {
                dataManager.createChat(participants: participants, message: message!, completion: completion)
            }
        }
    }
    
    // MARK: - Collection data
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: self.OutcomingColor)
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: self.IncomingColor)
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return tableViewData[indexPath.item]
    }
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 28;
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = tableViewData[indexPath.item]
        return NSAttributedString(string: self.senderName(for: message))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let message = tableViewData[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = tableViewData[indexPath.item]
        let image = self.avatarImage(for: message.senderId)
        let imageView = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 44)
        return imageView
    }
}
