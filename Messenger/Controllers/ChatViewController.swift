//
//  ChatViewController.swift
//  Messenger
//
//  Created by Makwana Bhavin on 08/06/22.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType{
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    
    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}

extension MessageKind{
    var messageKindString: String{
        switch self{
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType{
    public var photoURL: String
    public var senderId: String
    public var displayName: String
    
    init(photoUrl: String, senderId: String, displayName: String) {
        self.photoURL = photoUrl
        self.senderId = senderId
        self.displayName = displayName
    }
}

class ChatViewController: MessagesViewController {
    
    public static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    
    private let conversationId: String?
    
    public let otherUserEmail: String
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") else{
            return nil
        }
        return Sender(photoUrl: "", senderId: email as! String, displayName: "The Weeknd")
    }

    
    init(with email: String, id: String) {
        self.otherUserEmail = email
        self.conversationId = id
        super.init(nibName: nil, bundle: nil)
        guard let id = conversationId else{
            return
        }
        listenForMessages(id: id)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func listenForMessages(id: String){
        DatabaseManager.shared.getAllMessagesForConversation(with: id) {[weak self] result in
            switch result{
            case .success(let gotMessages):
                guard !gotMessages.isEmpty else{
                    return
                }
                self?.messages = gotMessages
                print("Is this what we want? \(self?.messages)")
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadData()
                }
                
            case .failure(let error):
                print("Failed to get message: \(error)")
            }
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMessageId() else{
            return
        }
        
        print("Sending: \(text)")
        //Send Message
        if isNewConversation{
            //Create convo in DB
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title ?? "User") { success in
                if success{
                    print("Message sent successfully.")
                }else{
                    print("Failed to send message.")
                }
                
            }
        }else{
            //Append to existing convo data
        }
        
    }
    
    private func createMessageId() -> String?{
        // date, otherUserEmail, senderEmail, randomInt
        
        guard let email = UserDefaults.standard.value(forKey: "email") else{
            return nil
        }
        let curruntUserEmail = DatabaseManager.safeEmail(emailAddress: email as! String)
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(curruntUserEmail)_\(dateString)"
        print("New identifier is created: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate{
    func currentSender() -> SenderType {
        if let sender = selfSender{
            return sender
        }
        fatalError("Self sender is nil, email should be catched.")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section] as! MessageType
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
}
