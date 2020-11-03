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

class ConversationModel: Searcher, ObservableObject {
    
    @ObservedObject var userModel: UserModel
    @Published var conversations = [Conversation]()
    
    var mc = ColorStrings()
    
    init(userModel: UserModel) {
        
        self.userModel = userModel
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        
        let db = Firestore.firestore()
        super.init(db: db)
//        listen()
        
    }
    
    //MARK: -Getting Conversations
    func listen() {
        print("snapshot listener being setup in conversation model")
        let conversationsRef = db.collection("rooms").order(by: "lastMessage", descending: true)
        
        if let profile = Auth.auth().currentUser {
            conversationsRef.whereField("allowedUsers", arrayContains: profile.uid).addSnapshotListener { (snapshot, error) in
                
                
                
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
                print(self.conversations)
            }
        }
    }
    
    func getNewestConversation(handler: @escaping (Conversation) -> Void) {
        
        db.collection("rooms").order(by: "created", descending: true).getDocuments { (snapshot, error) in
            if let documents = snapshot {
                
                for document in documents.documents {
                    
                    handler(self.getConversationFrom(document: document))
                    return
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
                                             "allowedUsers":[currentID],
                                             "name":title,
                                             "created":Date().timeIntervalSince1970,
                                             "lastMessage":Date().timeIntervalSince1970,
                                             "usersData":["defaultColors":[currentID:mc.blue],
                                                          "names":[currentID:sender],
                                                          "lastReadDates":[currentID:Date().timeIntervalSince1970]]]) { (error) in
            
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
        let lastMessage = document.data()["lastMessage"] as! Double
        let users = document.data()["users"] as! [String]
        let allowedUsers = document.data()["allowedUsers"] as! [String]
        let usersData = document.data()["usersData"] as! [String: [String:Any]]
        
        let names = usersData["names"] as! [String: String]
        let defaultColors = usersData["defaultColors"] as! [String: String]
        let lastReadDates = usersData["lastReadDates"] as! [String: Double]
        
        
        
        let conversation = Conversation(id: document.documentID,
                                        messagesPath: messagesPath,
                                        name: name,
                                        people: [ChiUser](),
                                        nameSummary: "",
                                        lastReadDates: lastReadDates,
                                        lastMessage: lastMessage,
                                        unreadMessages: 0,
                                        previewMessage: "",
                                        lastSenderColor: .black)
        
        for id in users {
            
            var user = ChiUser(id: id, color: "", name: "", colors: nil, allowed: true)
            let userName = names[id]!
            let userDefaultColor = defaultColors[id]!
            let userAllowed = allowedUsers.contains(id)
            
            if id == Auth.auth().currentUser?.uid {
                
                user.name = "Me"
                
            } else {
                
                user.name = userName
                
            }
            
            user.first = user.getFirst(from: user.name).description
            user.color = userDefaultColor
            user.cColor = user.getColorFrom(color: userDefaultColor)
            user.allowed = userAllowed
            
            
            let contact = getContactFromID(id: id)
            
            if contact.id != "" {
                //we already have a contact for the user we're loading
                
                user.colors = contact.colors
                user.name = contact.name
                if let color = contact.defaultColor {
                    user.color = color
                    
                }
                
                user.cColor = user.getColorFrom(color: user.color)
                user.first = user.getFirst(from: user.name) + ""
            }
            
            conversation.people.append(user)
            
        }
        
        conversation.name = self.decideName(name: conversation.name, people: conversation.people)
        
        var nameSummary = ""
        
        var allowedPeople = [ChiUser]()
        for person in conversation.people {
            if person.allowed {
                allowedPeople.append(person)
            }
        }
        
        for user in allowedPeople {
                if user.id == allowedPeople.first?.id {
                    
                    nameSummary = user.first + ""
                } else if user.id != allowedPeople.last?.id {
                    
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
    
    private func decideName(name: String, people: [ChiUser]) -> String {
        //TODO: make sure this is called after we get all the contacts
        
        var funcName = name
        
        //a check to make sure the people that we are considering are only the allowed people
        var allowedPeople = [ChiUser]()
        for person in people {
            if person.allowed {
                allowedPeople.append(person)
            }
        }
        
        if allowedPeople.count == 2 {
            
            if let profile = Auth.auth().currentUser {
                
                for user in allowedPeople {
                    
                    if user.id != profile.uid {
                        funcName = user.name
                    }
                }
            }
        }
        
        return funcName
    }
    
}

class Conversation: Identifiable, Equatable, ObservableObject {
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        
        
        
        //only check values that can change
        if lhs.id == rhs.id &&
            lhs.name == rhs.id &&
            lhs.people == rhs.people &&
            lhs.lastReadDates == rhs.lastReadDates &&
            lhs.lastMessage == rhs.lastMessage &&
            lhs.unreadMessages == rhs.unreadMessages &&
            lhs.previewMessage == rhs.previewMessage &&
            lhs.lastSenderColor == rhs.lastSenderColor {
            print("all listed values were the same")
            return true
        }
        
        return false
    }
    
    
    var id: String
    var messagesPath: CollectionReference
    @Published var name: String
    var people: [ChiUser]
    var nameSummary: String
    var lastReadDates: [String:Double]
    var lastMessage: Double
    @Published var unreadMessages: Int
    @Published var previewMessage: String
    @Published var lastSenderColor: Color
    
    init(id: String,
         messagesPath: CollectionReference,
         name: String,
         people: [ChiUser],
         nameSummary: String,
         lastReadDates: [String:Double],
         lastMessage: Double,
         unreadMessages: Int,
         previewMessage: String,
         lastSenderColor: Color) {
        
        self.id = id
        self.messagesPath = messagesPath
        self.name = name
        self.people = people
        self.nameSummary = nameSummary
        self.lastReadDates = lastReadDates
        self.lastMessage = lastMessage
        self.unreadMessages = unreadMessages
        self.previewMessage = previewMessage
        self.lastSenderColor = lastSenderColor
        
    }
    
}

struct ChiUser: Identifiable, Hashable {
    
    var id: String
    var name: String
    var color: String
    var colors: [String:String]?
    var cColor = Color.white
    var first = ""
    var allowed: Bool
    
    init(id: String, color: String, name: String, colors: [String:String]?, allowed: Bool) {
        
        self.id = id
        self.color = color
        self.name = name
        self.colors = colors
        self.allowed = allowed
        
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
        
        case cs.black:
            return cf.black
        case cs.darkGrey:
            return cf.darkGrey
        case cs.grey:
            return cf.grey
        case cs.sand:
            return cf.sand
            
        case cs.red :
            return cf.red
        case cs.maroon:
            return cf.maroon
        case cs.brown:
            return cf.brown
        case cs.coffe:
            return cf.coffe
            
        case cs.watermelon:
            return cf.watermelon
        case cs.orange:
            return cf.orange
        case cs.yellow:
            return cf.yellow
        case cs.lime:
            return cf.lime
            
        case cs.teal:
            return cf.teal
        case cs.mint:
            return cf.mint
        case cs.green:
            return cf.green
        case cs.forestGreen:
            return cf.forestGreen
            
        case cs.navyBlue:
            return cf.navyBlue
        case cs.skyBlue:
            return cf.skyBlue
        case cs.ice:
            return cf.ice
        case cs.pink:
            return cf.pink
            
        case cs.plum:
            return cf.plum
        case cs.blue:
            return cf.blue
        case cs.purple:
            return cf.purple
        case cs.magenta:
            return cf.magenta
        default:
            return cf.black
        }
    }
}
