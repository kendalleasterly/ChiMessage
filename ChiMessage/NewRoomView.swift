//
//  NewRoomView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI

struct NewRoomView: View {
    
    @ObservedObject var model = ConversationModel(userModel: UserModel())
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
                                        .foregroundColor(self.cf().card)
                                        .frame(width: 40, height: 40)
                                    
                                    //Content
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 22, weight: .bold))
                                    
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
                                        self.people.append(result)
                                    } label: {
                                        UserView(result: result)
                                    }
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
                            if message != "" {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 25.0, weight: .bold))
                            } else {
                                Image(systemName: "arrow.up.circle")
                                    .font(.system(size: 25.0, weight: .bold))
                            }
                        }).foregroundColor(self.cf().skyBlue)
                        
                    }.padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 15).foregroundColor(self.cf().black))
                    .padding()
                    
//                    HStack {
//
//                        TextField("chimessage", text: $message) { (changing) in } onCommit: {
//                            createRoomAndSend()
//                        }.padding(.horizontal, 30)
//                        .padding(.vertical, 10)
//                        .overlay(RoundedRectangle(cornerRadius: 50).strokeBorder(lineWidth: 2.5))
//                        .gesture(DragGesture().onEnded({ (value) in
//                            self.hideKeyboard()
//                        }))
//                        .accentColor(Color.white)
//
//                        Button {
//
//                            createRoomAndSend()
//
//                        } label: {
//                            if message != "" {
//                                Image(systemName: "arrow.up.circle.fill")
//                                    .font(.system(size: 40.0))
//                            } else {
//                                Image(systemName: "arrow.up.circle")
//                                    .font(.system(size: 40.0))
//                            }
//
//                        }.accentColor(self.cf().skyBlue)
//                    }.padding(.bottom, 5)
//                    .padding(.horizontal)
                }.background(Color.black.edgesIgnoringSafeArea(.all))
            
            
            
        }
    }
    
    func createRoomAndSend() {
        
        //TODO: add code here that makes sure that there is a group name and recipients
        if title != "" {
            model.addConvo(title: title) {
                
                model.getNewestConversation { (conversation) in
                    let messagesModel = MessagesModel(room: conversation)
                    messagesModel.addMessage(message: message)
                    
                    for person in self.people {
                        messagesModel.addUser(userID: person.id, name: person.name)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
