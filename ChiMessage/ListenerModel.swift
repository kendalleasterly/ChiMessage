//
//  ListenerModel.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/26/20.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class ListenerModel {
    
    var db: Firestore!
    
    init() {
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        db = Firestore.firestore()
        
        
    }
    
    func contactsListener(handler: @escaping ([Contact]) -> Void) -> ListenerRegistration? {
        
        if let profile = Auth.auth().currentUser {
            return db.collection("users").document(profile.uid).collection("contacts").addSnapshotListener { (snapshot, error) in
                print("listener in user model was triggered")
                
                if let documents = snapshot {
                    
                    var contactsArray = [Contact]()
                    
                    for document in documents.documents {
                        
                        let data = document.data()
                        
                        let name = data["name"] as! String
                        let defaultColor = data["color"] as? String
                        let colors = data["colors"] as? [String : String]
                        
                        let contact = Contact(id: document.documentID, name: name, defaultColor: defaultColor, colors: colors)
                        contactsArray.append(contact)
                        print("user model published to contact")
                        
                    }
                    
                    handler(contactsArray)
                    print("listener in user model caputured contacts array:")
                    print(contactsArray)
                    
                    
                } else {
                    print("documents could not be retrieved in contact listeners")
                }
            }
        } else {
            print("could not load profile")
            return nil
        }
        
    }
    
    
    func conversationsListener(handler: @escaping ([Conversation]) -> Void) -> ListenerRegistration? {
        
        let conversationsRef = db.collection("rooms").order(by: "lastMessage", descending: true)
        
        return conversationsRef.whereField("users", arrayContains: Auth.auth().currentUser?.uid).addSnapshotListener { (snapshot, error) in
            print("conversation listener was triggered")
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
            
            handler(conversationArray)
            
            print("conversation model caputured data:")
//            print(conversationArray)
        }
    }
    
//    func messagesListener(collection: CollectionReference, handler: @escaping ([MessageThread]) -> Void) -> ListenerRegistration {
//
//        let ref = collection
//
//        return ref.addSnapshotListener { (snapshot, error) in
//            print("messages listener was triggered")
//            guard let documents = snapshot?.documents else {
//
//                print("documents couldn't be fetched \(error!)")
//                return
//            }
//
//            var messageArray = [Message]()
//
//            for document in documents {
//
//                let message = document.data()["message"] as! String
//                let senderID = document.data()["sender ID"] as! String
//
//                let isUsers: Bool
//                if senderID == Auth.auth().currentUser?.uid {
//                    isUsers = true
//                } else {
//                    isUsers = false
//                }
//
//                self.getChiUserFromID(id: senderID) { (user) in
//
//                    if let colors = user.colors {
//                        if let color = colors[self.room.id] {
//                            messageArray.append(Message(id: document.documentID, message: message, userID: user.id, name: user.first, color: user.getColorFrom(color: color), isUsers: isUsers, index: messageArray.count))
//                        } else {
//                            //this one and the next one do the same, they are repeated because there can be rooms but this one may not be included
//                            messageArray.append(Message(id: document.documentID, message: message, userID: user.id, name: user.first, color: user.cColor, isUsers: isUsers, index: messageArray.count))
//                        }
//                    } else {
//                        //this is if there are no rooms at all
//                        messageArray.append(Message(id: document.documentID, message: message, userID: user.id, name: user.first, color: user.cColor, isUsers: isUsers, index: messageArray.count))
//                    }
//                }
//            }
//
//            var threadArray = [MessageThread]()
//
//            for message in messageArray {
//
//                //find out if the last value in the thread array has the same senderID as this message
//                if threadArray.last?.senderID == message.userID {
//                    //If it does, just append this message to the array in the last thread
//
//                    if var last = threadArray.last {
//
//                        last.array.append(message)
//                        threadArray[last.id] = last
//
//                    }
//                } else {
//                    //If it doesnt't, create a new thread with this message and message id, and append it to our array here
//                    let newThread = MessageThread(id: threadArray.count, senderID: message.userID, array: [message])
//                    threadArray.append(newThread)
//                }
//            }
//
//            handler(threadArray)
//            print("messages model caputured data")
//            print(threadArray)
//
//        }
//    }
    
    
    //MARK: -Helper functions
    
    private func getConversationFrom(document: QueryDocumentSnapshot) -> Conversation  {
        
        let messagesPath = document.reference.collection("messages")
        let name = document.data()["name"] as! String
        let colors = document.data()["defaultColors"] as! [String: String]
        let names = document.data()["names"] as! [String : String]
        let userIDs = document.data()["users"] as! [String]
        
        var conversation = Conversation(id: document.documentID,
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
            
            //NOTE: Somewhere around here there was a section that updated any users that are in the contacts database with their preferred values. That functionality has been moved and should now be used inside the handler of self. conversationsListener
            
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
    
}
