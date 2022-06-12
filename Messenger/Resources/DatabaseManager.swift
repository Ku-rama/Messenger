//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Makwana Bhavin on 02/06/22.
//

import Foundation
import FirebaseDatabase
import AVFoundation
import SwiftUI

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

//MARK: - Account Management

extension DatabaseManager{
    
    public func validateNewUser(with email: String,
                                completion: @escaping((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Insert new user to Database
    public func insertUser(with user: ChatAppUser, completion: @escaping(Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "firestName": user.firstName,
            "lastName": user.lastName
        ]) { error, _ in
            guard error == nil else{
                print("Failed to write to database.")
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]{
                    //Append to user dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }else{
                    //Create that dictionary
                    let newCollection : [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func getAllUsers(completion: @escaping(Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
    }
}

//MARK: - Sending Messages/Convo

extension DatabaseManager{
    
    // Create new convo with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String, completion: @escaping(Bool) -> Void){
        
        guard let curruntEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: curruntEmail)
        let ref = database.child(safeEmail)
        print(safeEmail)
        ref.observeSingleEvent(of: .value) { snapshot in
            print(snapshot.value)
            guard var userNode = snapshot.value as? [String: Any] else{
                completion(false)
                print("User not found.")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind{
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "otherUserEmail": otherUserEmail,
                "name": name,
                "latest_Message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                // Convo array exist for currunt user and we should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) {[weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversations(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    completion(true)
                }
                
            }else{
                // Convo array does not exist create a new one
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode) {[weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversations(name: name,conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    completion(true)
                }
            }
        }
    }
    
    private func finishCreatingConversations(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind{
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        
        let curruntUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": curruntUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages":[
                collectionMessage
            ]
        ]
        
        database.child(conversationID).setValue(value) { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
        
    }
    
    // Fetches and return all convo for user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["otherUserEmail"] as? String,
                      let latestMessage = dictionary["latest_Message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            }
            
            completion(.success(conversations))
        }
        
        
    }
    
    // Gets all messages for a given covo
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void){
        
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            
            let transferMessages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
////                      let isRead = dictionary["is_read"] as? Bool,
                      let dateString = dictionary["date"] as? String,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
////                      let type = dictionary["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString)
                else{
                    return nil
                }
                
//                print(name, dateString, messageId, content, senderEmail, date)
                
//                let sender = Sender(photoUrl: "", senderId: "1", displayName: "njabo")
//                let message = Message(sender: sender, messageId: "hello", sentDate: Date(), kind: .text("Hello"))
                
                let sender = Sender(photoUrl: "", senderId: senderEmail, displayName: name)
//
                let message = Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
                print(message)
                return message
                
                      
            }
            completion(.success(transferMessages))
        }
    }
    
    // Sends a message with target convo and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping(Bool) -> Void){
        
    }
    
    
    
}


struct ChatAppUser{
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String{
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String{
        return "\(safeEmail)_profile_picture.png"
    }
}

