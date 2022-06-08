//
//  StorageManager.swift
//  Messenger
//
//  Created by Makwana Bhavin on 08/06/22.
//

import Foundation
import FirebaseStorage

final class StorageMamager{
    static let shared = StorageMamager()
    
    private let storage = Storage.storage().reference()
    
    /// Upload pictue to firebase storage and returns completion with url string to download the image
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metadata, error in
            guard error == nil else{
                print("Failed to upload data to firebase picture.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else{
                    print("")
                    completion(.failure(StorageErrors.failedToDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print(urlString)
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToDownloadUrl
    }
    
    
}
