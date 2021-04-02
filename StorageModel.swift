//
//  StorageModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 11/13/20.
//

import SwiftUI
import Firebase
import FirebaseStorage


class StorageModel: ObservableObject {
    
    var storage = Storage.storage().reference()
    @Published var userImage = Image(systemName: "person.circle")
    
    func getActivityImage() {
        
        let imageRef = storage.child("userImages/activity.jpeg")
        
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            
            if let err = error {
                print("oh no we had an error \(err)")
            } else {
                
                if let uiImage = UIImage(data: data!) {
                    
                    self.userImage = Image(uiImage: uiImage)
                    
                } else {
                    print("oh no we had an error making image")
                }
            }
        }
    }
    
    func uploadImage(image: UIImage) {
        
        if let data = image.jpegData(compressionQuality: 1) {
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            storage.child("userImages/file.jpg").putData(data, metadata: metadata) { (metadata, error) in
                if let err = error {
                    
                    print(err)
                    
                } else {
                    print(metadata?.name)
                }
            }
            
        } else {
            print("couldnt make the url a url")
        }
        
    }
    
}
