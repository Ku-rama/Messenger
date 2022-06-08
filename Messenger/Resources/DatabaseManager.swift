//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Makwana Bhavin on 02/06/22.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
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
    public func insertUser(with user: ChatAppUser){
        database.child(user.safeEmail).setValue([
            "firestName": user.firstName,
            "lastName": user.lastName
        ])
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
}

