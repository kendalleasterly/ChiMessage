//
//  UserModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/21/20.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserModel: ObservableObject  {
    //In here, we get the user's document. Say for instance that we are unable to get the document because they never completed the sign up flow. Add functionality somewhere here that says that if we don't have a document and or it dosen't have the nesecarry information, then we instruct them to go through the process.
    let db: Firestore!
    @Published var contacts = [Contact]()
    var listenerModel = ListenerModel()
    var contactListener: ListenerRegistration?
    
    init() {
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        self.contactListener = listenerModel.contactsListener(handler: { (contacts) in
            self.contacts = contacts
        })
    }
}

//Handle sign up
extension UserModel {
    
    func sendName(firstName: String, lastName: String) {
        
        if let profile = Auth.auth().currentUser {
            
            db.collection("users").document(profile.uid).setData(["firstName":firstName, "lastName": lastName], merge: true)
            
        } else {
            print("profile didn't exist in send name")
        }
    }
    
    func sendUserName(userName: String) {
        //add something here that creates a room, and greets the user and tells them about the app. right now there is just an empthy view and no way to do anything
        if let profile = Auth.auth().currentUser {
            
            db.collection("users").document(profile.uid).setData(["userName": userName], merge: true)
        } else {
            print("profile was nil in send user name")
        }
    }
}

struct Contact: Identifiable {
    var id: String
    var name: String
    var defaultColor: String?
    var colors: [String : String]?
    
}

struct SearchResult: Identifiable {
    var id: String
    var name: String
    var userName: String
}
