//
//  MessagesModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI
import FirebaseFirestore
import GoogleSignIn
import FirebaseAuth

class MessagesModel: ObservableObject, Identifiable {
    
    @Published var messages = [MessageThread]()
    @Published var searchResults = [SearchResult]()
    var mc = ColorStrings()
    var db: Firestore!
    @Published var room: Conversation
    @ObservedObject var convoModel: ConversationModel
    
    init(room: Conversation, convoModel: ConversationModel) {
        
        self.room = room
        self.convoModel = convoModel
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        self.addListener(collection: room.messagesPath)
        print("messages model was initialized")
    }
    
    func addListener(collection: CollectionReference) {
        
        let ref = collection
        
        ref.addSnapshotListener { (snapshot, error) in
            print("messages listener was triggered")
            guard let documents = snapshot?.documents else {
                
                print("documents couldn't be fetched \(error!)")
                return
            }
            
            var messageArray = [Message]()
            
            for document in documents {
                
                let message = document.data()["message"] as! String
                let senderID = document.data()["sender ID"] as! String
                
                let isUsers: Bool
                if senderID == Auth.auth().currentUser?.uid {
                    isUsers = true
                } else {
                    isUsers = false
                }
                
                self.getChiUserFromID(id: senderID) { (user) in
                    
                    if let colors = user.colors {
                        if let color = colors[self.room.id] {
                            messageArray.append(Message(id: document.documentID, message: message, userID: user.id, name: user.first, color: user.getColorFrom(color: color), isUsers: isUsers, index: messageArray.count))
                        } else {
                            //this one and the next one do the same, they are repeated because there can be rooms but this one may not be included
                            messageArray.append(Message(id: document.documentID, message: message, userID: user.id, name: user.first, color: user.cColor, isUsers: isUsers, index: messageArray.count))
                        }
                    } else {
                        //this is if there are no rooms at all
                        messageArray.append(Message(id: document.documentID, message: message, userID: user.id, name: user.first, color: user.cColor, isUsers: isUsers, index: messageArray.count))
                    }
                }
            }
            
            var threadArray = [MessageThread]()
            
            for message in messageArray {
                
                //find out if the last value in the thread array has the same senderID as this message
                if threadArray.last?.senderID == message.userID {
                    //If it does, just append this message to the array in the last thread
                    
                    if var last = threadArray.last {
                        
                        last.array.append(message)
                        threadArray[last.id] = last
                        
                    }
                } else {
                    //If it doesnt't, create a new thread with this message and message id, and append it to our array here
                    let newThread = MessageThread(id: threadArray.count, senderID: message.userID, array: [message])
                    threadArray.append(newThread)
                }
            }
            
            self.messages = threadArray
            print("messages model caputured data")
//            print(threadArray)
            
        }
    }
    
    func getUpdatedConversation(handler: (Conversation) -> Void) {
        
        for conversation in convoModel.conversations {
            
            if conversation.id == self.room.id {
                handler(conversation)
            }
        }
    }
    
    func getChiUserFromID(id: String, handler: (ChiUser) -> Void) {
        
        getUpdatedConversation { (conversation) in
            for user in conversation.people {
                
                if user.id == id {
                    handler(user)
                }
            }
        }
        
    }
    
    func getMyChiUser() -> ChiUser {
        
        let id = Auth.auth().currentUser!.uid
        var funcUser = ChiUser(id: id, color: "", name: "", colors: nil)
        
        self.getChiUserFromID(id: id) { (user) in
            funcUser = user
        }
        
        return funcUser
    }
    
    func addMessage(message: String) {
        print("add message being called")
        if message != "" {
            let dbRef = self.room.messagesPath
            let date = Date().description
            
            if let currentUser = Auth.auth().currentUser {
                dbRef.document(date).setData(["message": message, "sender ID": currentUser.uid])
                db.collection("rooms").document(self.room.id).setData(["lastMessage":Date().timeIntervalSince1970], merge: true)
                
            } else {
                print("current user couldn't be used")
                
            }
        }
    }
    
    func addUser(userID: String, name: String) {
        
        let roomPath = db.collection("rooms").document(room.id)
        
        roomPath.getDocument(completion: { (snapshot, error) in
            if let document = snapshot {
                let users = document.data()!["users"] as! [String]
                
                if !users.contains(userID) {
                    roomPath.setData(["users": FieldValue.arrayUnion([userID]),
                                      "defaultColors": [userID: self.mc.array.randomElement() ?? "blue"],
                                      "names":[userID:name]],//I need to just add a dictionary entry with the person who we're about to add's id as the field and their name that we grab from the database as the value. I have not completed this code because I need to figure out how and where to grab their name, since its not the current user.
                                     merge: true)
                } else {
                    print("didn't add cause user is already in group")
                }
            }
        })
    }
    
    func removeUser(user: ChiUser) {
        
        db.collection("rooms").document(room.id).updateData(["users":FieldValue.arrayRemove([user.id])])
        
    }
    
    func changeName(to name: String) {
        
        db.collection("rooms").document(room.id).updateData(["name":name])
        
    }
    
    func updateContact(with contact: Contact) {
        
        if let profile = Auth.auth().currentUser {
            
            var data: [String: Any] = ["name": contact.name]
            
            if let defaultColor = contact.defaultColor {
                data.updateValue(defaultColor, forKey: "color")
            }
            
            if let colors = contact.colors {
                data.updateValue(colors, forKey: "colors")
            }
            
            db.collection("users").document(profile.uid).collection("contacts").document(contact.id).setData(data, merge: true)
            
        } else {
            print("couldn't load profile in update contact")
        }
    }
    
    func searchForUser(user: String, groupIDs: [String]) {
        
        if user != "" {
            //add something here that asks for the list of user ids that we already have, and add that to the search querey as a IS NOT Any
            db.collection("users").whereField("username", isGreaterThanOrEqualTo: user).whereField("username", notIn: groupIDs) .getDocuments { (snapshot, error) in
                
                if let documents = snapshot {
                    
                    var results = [SearchResult]()
                    
                    for document in documents.documents {
                        
                        let data = document.data()
                        let name = data["name"] as! String
                        let username = data["username"] as! String
                        
                        if user >= username[0] {
                            results.append(SearchResult(id: document.documentID, name: name, userName: username))
                        }
                    }
                    
                    self.searchResults = results
                    
                } else {
                    print("there was in error in search for user \(error)")
                }
            }
        }
    }
    
}

struct Message: Identifiable, Hashable {
    
    var id: String
    var message: String
    var userID: String
    var name: String
    var color: Color
    var isUsers: Bool
    var index: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ChiUser: Identifiable, Hashable {
    
//    let mc = ColorStrings()
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
