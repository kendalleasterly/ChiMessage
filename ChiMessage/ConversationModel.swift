//
//  ContentViewModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/16/20.
//

import SwiftUI
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth

class ConversationModel: ObservableObject {
    
    @ObservedObject var userModel: UserModel
    @Published var conversations = [Conversation]()
    
    var db: Firestore!
    var mc = ColorStrings()
    
    init(userModel: UserModel) {
        
        self.userModel = userModel
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        listen()
        
    }
    
    //MARK: -Getting Conversations
    private func listen() {
        
        let conversationsRef = db.collection("rooms").order(by: "lastMessage", descending: true)
        
        if let profile = Auth.auth().currentUser {
            conversationsRef.whereField("users", arrayContains: profile.uid).addSnapshotListener { (snapshot, error) in
                
                guard let conversatons = snapshot else {
                    print("no current conversations ")
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
                
            }
        }
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
    
    //MARK: -Creating Conversations
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
                print("there was an error adding conversation")
            }
        }
    }
    
    //MARK: -Misc.
    func signOut() {
        
        GIDSignIn.sharedInstance()?.signOut()
    }
    
    //MARK: -Helper Functions
    private func getConversationFrom(document: QueryDocumentSnapshot) -> Conversation  {
        
        let messagesPath = document.reference.collection("messages")
        let name = document.data()["name"] as! String
        let colors = document.data()["defaultColors"] as! [String: String]
        let names = document.data()["names"] as! [String : String]
        let userIDs = document.data()["users"] as! [String]
        
        let conversation = Conversation(id: document.documentID,
                                        messagesPath: messagesPath,
                                        name: name,
                                        people: [ChiUser](),
                                        nameSummary: "",
                                        date: Date())
        
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
    
    private func getContactFromID(id: String) -> Contact {
        
        let contact = Contact(id: "", name: "", defaultColor: "", colors: [String:String]())
        
        for funcContact in userModel.contacts {
            
            if funcContact.id == id {
                return funcContact
            }
        }
        
        return contact
        
    }
}

class Conversation: Identifiable {
    
    var id: String
    var messagesPath: CollectionReference
    var name: String
    var people: [ChiUser]
    var nameSummary: String
    var date: Date
    
    init(id: String, messagesPath: CollectionReference, name: String, people: [ChiUser], nameSummary: String, date: Date) {
        
        self.id = id
        self.messagesPath = messagesPath
        self.name = name
        self.people = people
        self.nameSummary = nameSummary
        self.date = date
        
    }
    
}

struct ChiUser: Identifiable, Hashable {
    
    var id: String
    var name: String
    var color: String
    var colors: [String:String]?
    var cColor = Color.white
    var first = ""
    
    init(id: String, color: String, name: String, colors: [String:String]?) {
        
        self.id = id
        self.color = color
        self.name = name
        self.colors = colors
        
        self.cColor = getColorFrom(color: color)
    }
    
    func getFirst(from name: String) -> String.SubSequence {
        
        if name != "" {
            let funcFirst = name.split(separator: " ")[0]
            return funcFirst
        } else {
            return "?"
        }
    }
    
    func getColorFrom(color: String) -> Color {
        
        let cf = ContentView().cf()
        let cs = ColorStrings()
        
        switch color {
        
        case cs.maroon:
            return cf.maroon
        case cs.red:
            return cf.red
        case cs.orange:
            return cf.orange
        case cs.yellow:
            return cf.yellow
        case cs.lime:
            return cf.lime
        case cs.forestGreen:
            return cf.forestGreen
        case cs.green:
            return cf.green
        case cs.mint:
            return cf.mint
        case cs.skyBlue:
            return cf.skyBlue
        case cs.ice:
            return cf.ice
        case cs.teal:
            return cf.teal
        case cs.navyBlue:
            return cf.navyBlue
        case cs.blue:
            return cf.blue
        case cs.purple:
            return cf.purple
        case cs.magenta:
            return cf.magenta
        case cs.pink:
            return cf.pink
        case cs.plum:
            return cf.plum
        case cs.brown:
            return cf.brown
        case cs.coffe:
            return cf.coffe
        case cs.sand:
            return cf.sand
        case cs.grey:
            return cf.grey
        case cs.darkGrey:
            return cf.darkGrey
        case cs.black:
            return cf.black
        default:
            return cf.black
        }
    }
}
