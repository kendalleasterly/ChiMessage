//
//  GoogleDelagate.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/16/20.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn

class GoogleDelagate: NSObject, GIDSignInDelegate, ObservableObject {
    @Published var isCreation = false
    @Published var user = GIDGoogleUser()
    var navModel = NavigationModel()
    var db: Firestore!
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print(err.localizedDescription)
            return
        }
        
        self.user = user
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            
            if let error = error {
               print("error in signing in with google was \(error)")
                
                return
            }
            
            if let profile = Auth.auth().currentUser {
                
                let creationDate = profile.metadata.creationDate!.description
                let lastSignIn = profile.metadata.lastSignInDate!.description
                
                if creationDate == lastSignIn {
                    //Make sure that this is the first time, because there is a huge time delay in the last sign in time in the auth object. It'll be a background read, so I don't need the update immediately. The optimal is the sign in flow doesn't show at all because we've already done it, but what I think will happen is that It will show for a short period of time while I am checking to see if we have the document and its information, and then when it comes back true it will then transition to the conversation view.
                    print("this is first time")
                    self.isCreation = true
                } else {
                    print("we have an account")
                }
                
            }
            
            self.navModel.conversationLinkActive = true
//            self.updateUserStatus()
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
        print("user disconnected")
    }
    
//    func updateUserStatus() {
//
//        let settings = FirestoreSettings()
//        Firestore.firestore().settings = settings
//
//        db = Firestore.firestore()
//
//        if let currentUser = Auth.auth().currentUser {
//
//            guard let profile = GIDSignIn.sharedInstance().currentUser.profile else {
//                print("something wrong with getting profile")
//                return
//            }
//
//            let name = profile.givenName! + " " + profile.familyName!
//
//            db.collection("users").document(currentUser.uid).setData(["name": name])
//        } else {
//            print("currentUser couldn't be found")
//        }
//    }
}
