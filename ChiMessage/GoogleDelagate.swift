//
//  GoogleDelagate.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/16/20.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

class GoogleDelagate: NSObject, GIDSignInDelegate, ObservableObject {
    @Published var isCreation = false
    @Published var user = GIDGoogleUser()
    
    var navModel = NavigationModel()
    
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
                    
                    self.isCreation = true
                } else {
                    
                }
                
            }
            
            self.navModel.conversationLinkActive = true
            
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
}
