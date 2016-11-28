//
//  MessagesViewController.swift
//  Teams
//
//  Created by Anton Novoselov on 27/11/2016.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse
import Photos
import JSQMessagesViewController
import ImagePickerSheetController



class MessagesViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - Public API
    var conversation: Conversation!
    var incomingUser: User!
    
    // MARK: - Private
    
    private let currentUser = PFUser.current()!
    private var users = [User]()
    
    private var jsqMessages = [JSQMessage]()        // data source, message presented locally
    private var messages = [Message]()          // message downloaded from parse
    
    private var outgoingBubbleImage: JSQMessagesBubbleImage!
    private var incomingBubbleImage: JSQMessagesBubbleImage!
    
    private var selfAvatar: JSQMessagesAvatarImage!
    private var incomingAvatar: JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delete? CGSizeZero
        
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 16.0, height: 16.0)
        
        // camera button
        self.inputToolbar?.contentView?.leftBarButtonItem?.setImage(UIImage(named: "Camera"), for: .normal)
        self.inputToolbar?.contentView?.leftBarButtonItem?.setImage(UIImage(named: "Camera"), for: .highlighted)
        self.inputToolbar?.contentView?.leftBarButtonItem?.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        title = incomingUser.username!
        self.senderId = currentUser.objectId!
        self.senderDisplayName = currentUser.username!
        
        setupAvatarImages()
        createMessagesBubbles()
        
        loadMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.keyboardController?.textView?.becomeFirstResponder()
    }
    
    func setupAvatarImages() {
        
        incomingUser.profileImageFile.getDataInBackground { (data, error) -> Void in
            if error == nil && data != nil {
                self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: data!)!, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            }
        }
        
        (currentUser as! User).profileImageFile.getDataInBackground { (data, error) -> Void in
            if error == nil && data != nil {
                self.selfAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: data!)!, diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            }
        }
    }
    
    func createMessagesBubbles() {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImage = bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 12/255.0, green: 133.0/255.0, blue: 254.0/255.0, alpha: 1))
        
        incomingBubbleImage = bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 229.0/255.0, green: 229.0/255.0, blue: 234.0/255.0, alpha: 1))
    }
    
    // MARK: - Load Messages
    
    func loadMessages() {
        var lastMessage: JSQMessage? = nil
        
        if jsqMessages.last != nil {
            lastMessage = jsqMessages.last
        }
        
        // query all the messages in the conversation
        let messageQuery = PFQuery(className: Message.parseClassName())
        
        messageQuery.whereKey("conversationId", equalTo: (conversation?.objectId!)!)
        messageQuery.order(byAscending: "createdAt")
        
//        messageQuery.limit = 100
        messageQuery.cachePolicy = .networkElseCache
        messageQuery.includeKey("sender")
        
        if lastMessage != nil {
            messageQuery.whereKey("createdAt", greaterThan: (lastMessage?.date)!)
        }
        
        messageQuery.findObjectsInBackground { (objects, error) -> Void in
            if error == nil {
                
                if let objects = objects as [PFObject]! {
                    
                    for object in objects {
                        
                        let message = object as! Message
                        self.messages.append(message)           // the messages we download from parse
                        
                        let sender = message.sender as! User
                        self.users.append(sender)
                        
                        // TEXT MESSAGE
                        if message.photoFile == nil {
                            // this is a text msg
                            let jsqMessage = JSQMessage(senderId: sender.objectId!, senderDisplayName: sender.username!, date: message.createdAt!, text: message.text)
                            
                            self.jsqMessages.append(jsqMessage!)
                            //                            print("text from \(sender.username!) \(sender.objectId!)")
                            
                            if objects.count != 0 {
                                self.finishReceivingMessage()
                            }
                            // PHOTO MESSAGE
                        } else {
                            
                            let photoMediaItem = JSQPhotoMediaItem(image: nil)
                            
                            photoMediaItem?.appliesMediaViewMaskAsOutgoing = sender.objectId == self.currentUser.objectId
                            
                            
//                            photoMediaItem?.appliesMediaViewMaskAsOutgoing = false
                            
                            var newMessage = JSQMessage(senderId: sender.objectId!, displayName: sender.username!, media: photoMediaItem)
                            self.jsqMessages.append(newMessage!)
                            
                            message.photoFile.getDataInBackground(block: { (data, error) -> Void in
                                if error == nil && data != nil {
                                    photoMediaItem?.image = UIImage(data: data!)!
                                    newMessage = JSQMessage(senderId: message.sender.objectId!, displayName: message.sender.username!, media: photoMediaItem)
                                    
                                    if objects.count != 0 {
                                        self.finishReceivingMessage()
                                    }
                                }
                            })
                        }
                    }
                    
                    
                    
                }
                
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // MARK: - Send Messages
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let message = Message(text: text, sender: PFUser.current()!, conversationId: conversation.objectId!)
        
        message.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.conversation.lastUpdate = NSDate()
                self.conversation.saveInBackground()
                
                self.loadMessages()
            }
            
            self.finishSendingMessage()
        }
    }
    
    
    
    func sendPhoto(photo: UIImage) {
        let message = Message(photo: photo, sender: PFUser.current()!, conversationId: conversation.objectId!)
        
        message.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.conversation.lastUpdate = NSDate()
                self.conversation.saveInBackground()
                
                self.loadMessages() // reload the messages
            }
            
            self.finishSendingMessage()
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                
                DispatchQueue.main.async {
                    self.didPressAccessoryButton(sender)

                }
            })
            return
        }
        
        if authorization == .authorized {
            
            let controller = ImagePickerSheetController(mediaType: .image)
            
            controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Use this Photo", comment: "Action Title"), handler: { _ in
                
                self.presentCamera()
                
            }, secondaryHandler: { _, numberOfPhotos in
                
                print("secondaryHandler, numberOfPhotos = \(numberOfPhotos)")
                
                let selectedAsset = controller.selectedAssets[0]
                
                let selectedImage = self.getAssetThumbnail(asset: selectedAsset)
                
                self.sendPhoto(photo: selectedImage)
                
            }))
            
            controller.addAction(ImagePickerAction(title: NSLocalizedString("Cancel", comment: "Action Title"), style: .cancel, handler: { _ in
                print("Cancelled")
            }))
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: - Present the camera
    
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        
        let maxSize = PHImageManagerMaximumSize
        
        manager.requestImage(for: asset, targetSize: maxSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        
        
        return thumbnail
    }

    
    func presentCamera() {
        // CHALLENGE: present normla image picker controller
        //              update the postImage + postImageView
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        sendPhoto(photo: info[UIImagePickerControllerOriginalImage] as! UIImage)
        picker.dismiss(animated: true, completion: nil)
    }
    

    
    
    // MARK: - JSQMessageViewController
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return jsqMessages[indexPath.row]
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = jsqMessages[indexPath.item]
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        
        return incomingBubbleImage
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let messsage = jsqMessages[indexPath.row]
        
        if messsage.senderId == self.senderId {
            return selfAvatar
        }
        
        return incomingAvatar

    }
    
    // for the time stamp
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        // For eacth 10th message specify timestamp
        if indexPath.item % 10 == 0 {
            let message = jsqMessages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        if indexPath.item % 10 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0

    }
    
   
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let jsqMessage = jsqMessages[indexPath.item]
        if jsqMessage.media != nil { // this is a photo message
            if let imageView = jsqMessage.media.mediaView() as? UIImageView {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let photoViewController = storyboard.instantiateViewController(withIdentifier: "PhotoViewController") as! PhotoViewController
                photoViewController.image = imageView.image
                photoViewController.senderName = jsqMessage.senderDisplayName
                self.navigationController?.pushViewController(photoViewController, animated: true)
            }
        }

    }
    
    // MARK: - JSQMessageViewContorller Datasource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsqMessages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = jsqMessages[indexPath.item]
        
        if message.media == nil {
            if message.senderId == self.senderId {
                cell.textView?.textColor = UIColor.white
            } else {
                cell.textView?.textColor = UIColor.black
            }
            
            cell.textView?.linkTextAttributes = [NSForegroundColorAttributeName : cell.textView!.textColor!]
        }
        
        return cell
    }
    
    
}


