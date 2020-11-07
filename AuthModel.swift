//
//  AuthModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI
import FirebaseAuth
import Firebase

class AuthModel: ObservableObject {
    
    @Published var isSignedIn = false
    var db: Firestore!
    
    init() {
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()

        listen()
        
    }
    
    func listen() {
        
        Auth.auth().addStateDidChangeListener({ (authResult, user) in
            
            
            if let funcUser = user {
                if let profile = Auth.auth().currentUser {
                    
                    print(profile.uid)
                    
                }
                self.isSignedIn = true
            } else {
                print("we not signed in")
                self.isSignedIn = false
            }
            
        })
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            
            print("therer was erer")
        }
    }
    
    func createUser(email: String, password: String, name: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [self] (result, error) in
            
            if let requestResult = result {
                
                print(requestResult.credential?.provider)
                if let profile = Auth.auth().currentUser {
                   var changeRequest =  profile.createProfileChangeRequest()
                    changeRequest.displayName = name
                    changeRequest.commitChanges { (error) in
                        if let err = error {
                            print(err)
                        } else {
                            print(profile.displayName)
                        }
                    }
                    
                    db.collection("users").document(profile.uid).setData(["name": name, "username": name])
                }
                
                
            } else {
                print(error)
            }
            
        }
        
    }
    
}

