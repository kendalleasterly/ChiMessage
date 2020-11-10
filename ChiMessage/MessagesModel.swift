//
//  MessagesModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class MessagesModel: Searcher, ObservableObject, Identifiable {
    
    @Published var messages = [MessageThread]()
    @ObservedObject var convo: Conversation {
        didSet {
            
            listen()
        }
    }
    
    var mc = ColorStrings()
    
    init(room: Conversation?) {
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        let db = Firestore.firestore()
        
        
        if let convo = room {
            self.convo = convo
            
        } else {
            self.convo = Conversation(id: "", messagesPath: db.collection("users"), name: "", people: [ChiUser](), nameSummary: "", lastReadDates: ["":0], lastMessage: 0, unreadMessages: 0, previewMessage: "", lastSenderColor: .white)
        }
        
        super.init(db: db)
        
        if room != nil {
            
            listen()
            
        }
        
    }
    
    //MARK: -Reading
    func listen() {
        
        let ref = convo.messagesPath
        
        ref.addSnapshotListener { (snapshot, error) in
            
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
                        if let color = colors[self.convo.id] {
                            messageArray.append(Message(id: document.documentID, message: message, senderID: user.id, name: user.name, color: user.getColorFrom(color: color), isUsers: isUsers, index: messageArray.count))
                        } else {
                            //this one and the next one do the same, they are repeated because there can be rooms but this one may not be included
                            messageArray.append(Message(id: document.documentID, message: message, senderID: user.id, name: user.name, color: user.cColor, isUsers: isUsers, index: messageArray.count))
                        }
                    } else {
                        //this is if there are no rooms at all
                        messageArray.append(Message(id: document.documentID, message: message, senderID: user.id, name: user.name, color: user.cColor, isUsers: isUsers, index: messageArray.count))
                    }
                }
            }
            
            self.updateConversation(messages: messageArray)
            
            var threadArray = [MessageThread]()
            
            for message in messageArray {
                
                //find out if the last value in the thread array has the same senderID as this message
                if threadArray.last?.senderID == message.senderID {
                    //If it does, just append this message to the array in the last thread
                    if var last = threadArray.last {
                        
                        last.array.append(message)
                        threadArray[last.id] = last
                        
                    }
                } else {
                    //If it doesnt't, create a new thread with this message and message id, and append it to our array here
                    let newThread = MessageThread(id: threadArray.count, senderID: message.senderID, array: [message])
                    threadArray.append(newThread)
                }
            }
            
            self.messages = threadArray
        }
    }
    
    //MARK: -User Editing
    
    func addUser(userID: String, name: String) {
        
        let roomPath = db.collection("rooms").document(convo.id)
        
        roomPath.getDocument(completion: { (snapshot, error) in
            if let document = snapshot {
                let users = document.data()!["users"] as! [String]
                
                if !users.contains(userID) {
                    roomPath.setData(["users": FieldValue.arrayUnion([userID]),
                                      "allowedUsers":FieldValue.arrayUnion([userID]),
                                      "usersData":["defaultColors": [userID: self.mc.array.randomElement() ?? "skyBlue"],
                                                   "names":[userID:name],
                                                   "lastReadDates":[userID: 0]]],//I need to just add a dictionary entry with the person who we're about to add's id as the field and their name that we grab from the database as the value. I have not completed this code because I need to figure out how and where to grab their name, since its not the current user.
                                     merge: true)
                } else {
                    print("didn't add cause user is already in group")
                }
            }
        })
    }
    
    func removeUser(user: ChiUser) {
        
        db.collection("rooms").document(convo.id).setData(["allowedUsers":FieldValue.arrayRemove([user.id])], merge: true)
        //setData(["usersData":["allowedUsers":[user.id]]], merge: true)
        //we find the users data object, we find the removed object, we find the users object, and we set their removed value to true
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
    
    //MARK: -Conversation Editing
    
    func addMessage(message: String) {
        
        if message != "" {
            let dbRef = self.convo.messagesPath
            let date = Date().timeIntervalSince1970.description
            
            if let currentUser = Auth.auth().currentUser {
                dbRef.document(date).setData(["message": message, "sender ID": currentUser.uid])
                db.collection("rooms").document(self.convo.id).setData(["lastMessage":Date().timeIntervalSince1970], merge: true)
                
            } else {
                print("current user couldn't be used")
                
            }
        }
    }
    
    func changeName(to name: String) {
        print("change name being called with \(name)")
        db.collection("rooms").document(convo.id).setData(["name":name], merge: true)
        
    }
    
    func updateReadStatus() {
        
        if let profile = Auth.auth().currentUser {
            self.db.collection("rooms").document(self.convo.id).setData(["usersData":["lastReadDates":[profile.uid: Date().timeIntervalSince1970]]], merge: true)
        } else {
            print("didn't update read status cause profile wasn't available")
        }
        
    }
    
    //MARK: -Helper Functions
    
    private func getChiUserFromID(id: String, handler: (ChiUser) -> Void) {
        
        for user in convo.people {
            
            if user.id == id {
                handler(user)
            }
        }
    }
    
    func getMyChiUser() -> ChiUser {
        
        let id = Auth.auth().currentUser!.uid
        var funcUser = ChiUser(id: id, color: "", name: "", colors: nil, allowed: true)
        
        self.getChiUserFromID(id: id) { (user) in
            funcUser = user
        }
        
        return funcUser
    }
    //TODO: fix the two-person contact color for message view
    private func updateConversation(messages: [Message]) {
        var amount = 0
        
        if let profile = Auth.auth().currentUser {
            let lastReadDate = self.convo.lastReadDates[profile.uid]
            
            for message in messages {
                
                if String(lastReadDate!) < message.id  {
                    if !message.isUsers {
                        amount = amount + 1
                    }
                }
            }
        }
        
        self.convo.unreadMessages = amount
        if let lastMessage = messages.last {
            self.convo.previewMessage = lastMessage.message
            self.convo.lastSenderColor = lastMessage.color
        }
        
    }
    
    
//    func updateThread(contact: Contact) {
//        
//        var i = 0
//        
//        var people = convo.people
//        
//        for user in people {
//            
//            
//            if user.id == contact.id {
//                
//                people.remove(at: i)
//                user.
//                
//            }
//            
//            i = i + 1
//        }
//        
//        
//    }
    
    
    
}

struct Message: Identifiable, Hashable {
    
    var id: String
    var message: String
    var senderID: String
    var name: String
    var color: Color
    var isUsers: Bool
    var index: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct MessageThread:Identifiable, Hashable {
    
    var id: Int
    var senderID: String
    var array: [Message]
    
}
