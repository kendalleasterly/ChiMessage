//
//  ContentViewModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/16/20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth

class ConversationModel: ObservableObject {
    
    var db: Firestore!
    @ObservedObject var userModel: UserModel
    @Published var conversations = [Conversation]()
    var mc = ColorStrings()
    
    init(userModel: UserModel) {
        
        self.userModel = userModel
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        conversationListeners()
    }
    
    func conversationListeners() {
        
        let conversationsRef = db.collection("rooms").order(by: "lastMessage", descending: true)
        
        conversationsRef.whereField("users", arrayContains: Auth.auth().currentUser?.uid).addSnapshotListener { (snapshot, error) in
            print("conversation listener is running")
            guard let conversatons = snapshot else {
                print("no current conversations \(error?.localizedDescription)")
                return
            }
            
            var conversationArray = [Conversation]()
            
            for document in conversatons.documents {
                
                let conversation = self.getConversationFrom(document: document)
                
                for convo in conversationArray {
                    if convo.id == conversation.id {
                        return
                    }
                }
                
                conversationArray.append(conversation)
            }
            
            self.conversations = conversationArray
            print("conversation model published to conversations")
            
        }
    }
    
    func addConvo(title: String, handler: @escaping () -> Void) {
        
        guard let profile = GIDSignIn.sharedInstance().currentUser.profile else {
            print("something wrong with profile")
            
            return
        }
        let sender = "\(profile.givenName!) \(profile.familyName!)"
        let currentID = Auth.auth().currentUser?.uid
        db.collection("rooms").addDocument(data:
                                            ["users":[currentID],
                                             "name":title,
                                             "created":Date().timeIntervalSince1970,
                                             "defaultColors":[currentID : mc.blue],
                                             "names":[currentID:sender]]) { (error) in
            
            if error == nil {
                
                handler()
            } else {
                print("there was an error adding conversation \(error)")
            }
        }
    }
    
    func signOut() {
        
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    func getNewestConversation(handler: @escaping (Conversation) -> Void) {
        
        db.collection("rooms").order(by: "created", descending: true).getDocuments { (snapshot, error) in
            if let documents = snapshot {
                
                for document in documents.documents {
                    
                    handler(self.getConversationFrom(document: document))
                    
                }
            } else {
                print("error getting newestconversation")
            }
        }
    }
    
    func getConversationFrom(document: QueryDocumentSnapshot) -> Conversation  {
        
        let messagesPath = document.reference.collection("messages")
        let name = document.data()["name"] as! String
        let colors = document.data()["defaultColors"] as! [String: String]
        let names = document.data()["names"] as! [String : String]
        let userIDs = document.data()["users"] as! [String]
        
        var conversation = Conversation(id: document.documentID,
                                        messagesPath: messagesPath,
                                        name: name,
                                        people: [ChiUser](),
                                        nameSummary: "")
        
        for id in userIDs {
            
            var user = ChiUser(id: id, color: "", name: "", colors: nil)
            
            if let color = colors[id] {
                if let userName = names[id] {
                    if id == Auth.auth().currentUser?.uid {
                        
                        user.name = "Me"
                        
                    } else {
                        
                        user.name = userName
                        
                    }
                    
                    user.color = color
                    user.cColor = user.getColorFrom(color: color)
                    user.first = user.getFirst(from: user.name) + ""
                    conversation.people.append(user)
                    
                } else {
                    print("there was no name for that id")
                }
            } else {
                print("there was no color for that id")
            }
            
            let contact = getContactFromID(id: id)
            
            if contact.id != "" {
                //we already have a contact for the user we're loading
                conversation.people.removeLast()
                
                user.colors = contact.colors
                user.name = contact.name
                if let color = contact.defaultColor {
                    user.color = color
                    
                }
                
                user.cColor = user.getColorFrom(color: user.color)
                user.first = user.getFirst(from: user.name) + ""
                conversation.people.append(user)
            }
        }
        
        var nameSummary = ""
        
        for user in conversation.people {
            if user.id == conversation.people.first?.id {
                
                nameSummary = user.first + ""
            } else if user.id != conversation.people.last?.id {
                
                nameSummary = nameSummary + ", " + user.first
            } else {
                
                nameSummary = nameSummary + " & " + user.first
            }
        }
        
        conversation.nameSummary = nameSummary
        
        return conversation
    }
    
    func getContactFromID(id: String) -> Contact {
        
        let contact = Contact(id: "", name: "", defaultColor: "", colors: [String:String]())
        
        for funcContact in userModel.contacts {
            
            if funcContact.id == id {
                return funcContact
            }
        }
        
        return contact
        
    }
    
//    func getConversationFromId(id: String) ->  Conversation {
//
//        for convo in self.conversations {
//
//            if convo.id == id {
//                return convo
//            }
//
//        }
//
//        return nil
//    }
    
}

struct Conversation: Identifiable {
    
    var id: String
    var messagesPath: CollectionReference
    var name: String
    var people: [ChiUser]
    var nameSummary: String
}
