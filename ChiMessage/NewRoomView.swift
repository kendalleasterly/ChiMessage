//
//  NewRoomView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI

struct NewRoomView: View {
    
    @ObservedObject var model: ConversationModel
    @Environment(\.presentationMode) var presentationMode
    
    @State var title = ""
    @State var person = ""
    @State var message = ""
    @State var people = [SearchResult]()
    
    var body: some View {
        GeometryReader { reader in
            
            VStack{
                ZStack {
                    
                    //Background bar
                    Rectangle()
                        .foregroundColor(self.cf().background)
                        .background(Blur())
                        .frame(width: reader.size.width, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    
                    //Main content
                    VStack {
                        
                        //Group Photo and Name
                        HStack {
                            
                            //Card
                            ZStack {
                                //Background
                                Circle()
                                    .foregroundColor(self.cf().black)
                                    .frame(width: 40, height: 40)
                                
                                //Content
                                
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                
                                
                            }
                            
                            //Name
                            TextField("New Group", text: $title) { (changing) in } onCommit: { }
                                .font(.system(size: 28, weight: .bold))
                            
                        }
                        
                        //People
                        
                        HStack {
                            
                            TextField("Add People", text: $person).onChange(of: self.person) { (value) in
                                
                                if value != "" {
                                    
                                    model.searchForUser(user: value)
                                    print(model.searchResults)
                                }
                                
                            }.padding(.leading, 50)
                        }
                    }.padding(.leading, 20)
                    
                }
                
                ScrollView{
                    
                    VStack{
                        
                        if !model.searchResults.isEmpty && self.person != ""{
                            ForEach(model.searchResults) {result in
                                Button {
                                    if !self.people.contains(result) {
                                        self.people.append(result)
                                    }
                                    
                                } label: {
                                    UserView(result: result)
                                }
                                
                                Divider()
                                
                            }
                        }
                    }
                }.padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                //Bottm row, Textfield and send button
                
                HStack {
                    
                    TextField("chimessage", text: $message) { (changing) in } onCommit: {
                        createRoomAndSend()
                    }.gesture(DragGesture().onEnded({ (value) in
                        self.hideKeyboard()
                    }))
                    
                    Button(action: {
                        
                        createRoomAndSend()
                        
                    }, label: {
                        if conditionsMet(){
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 25.0, weight: .bold))
                        } else {
                            Image(systemName: "arrow.up.circle")
                                .font(.system(size: 25.0, weight: .bold))
                        }
                    }).foregroundColor(self.cf().skyBlue)
                    .disabled(!conditionsMet())
                    
                }.padding(.vertical, 10)
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 15).foregroundColor(self.cf().black))
                .padding()
            }.background(Color.black.edgesIgnoringSafeArea(.all))
            
            
            
        }
    }
    
    func conditionsMet() -> Bool {
        
        if message != "" && !people.isEmpty && title != ""{
            return true
        } else {
            return false
        }
    }
    
    func createRoomAndSend() {
        print("create room an send is running")
        
        //go through each conversation
        for conversation in model.conversations {
            //go through each peerson in each conversaton
            
            var peopleIDs = [String]()
            
            var allowedPeople = [ChiUser]()
            for person in conversation.people {
                if person.allowed {
                    allowedPeople.append(person)
                }
            }
            print(allowedPeople)
            //convert my array of chiusers to an array of their ids
            for person in allowedPeople {
                
                peopleIDs.append(person.id)
            }
            print(peopleIDs)
            //we start at 1 because we need to include myself.
            var samePeople = 1
            print(people)
            for member in people {
                
                if peopleIDs.contains(member.id) {
                    samePeople = samePeople + 1
                }
                
            }
            print(samePeople)
            
            if samePeople == conversation.people.count {
                presentationMode.wrappedValue.dismiss()
                return
            }
        }
        
        if title != "" {
            model.addConvo(title: title) {
                print("created a conversation with title \(title)")
                
                model.getNewestConversation { (conversation) in
                    print("the newest conversation was \(conversation.name)")
                    let messagesModel = MessagesModel(room: conversation)
                    messagesModel.addMessage(message: message)
                    print("added message")
                    for person in self.people {
                        messagesModel.addUser(userID: person.id, name: person.name)
                        print("added \(person.name) to \(conversation.name)")
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
    }
}
