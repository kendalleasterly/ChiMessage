//
//  UserModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/21/20.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

//In here, we get the user's document. Say for instance that we are unable to get the document because they never completed the sign up flow. Add functionality somewhere here that says that if we don't have a document and or it dosen't have the nesecarry information, then we instruct them to go through the process.

//TODO: add a way for the user to search for people. Make sure you include search results for results based on names and usernames, but only show one result once (i.e. showing a a result for tim cook from the username and timcook

class UserModel: ObservableObject  {
    
    @Published var contacts = [Contact]()
    
    let db: Firestore!
    
    init() {
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        listen()
    }
    
    func listen() {
        
        if let profile = Auth.auth().currentUser {
            
            db.collection("users").document(profile.uid).collection("contacts").addSnapshotListener { (snapshot, error) in
                
                if let documents = snapshot {
                    
                    var contactsArray = [Contact]()
                    
                    for document in documents.documents {
                        
                        let data = document.data()
                        
                        let name = data["name"] as! String
                        let defaultColor = data["color"] as? String
                        let colors = data["colors"] as? [String : String]
                        
                        let contact = Contact(id: document.documentID, name: name, defaultColor: defaultColor, colors: colors)
                        contactsArray.append(contact)
                        
                        
                    }
                    
                    self.contacts = contactsArray
                    
                } else {
                    print("documents could not be retrieved in contact listeners")
                }
            }
        } else {
            print("could not load profile")
        }
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

