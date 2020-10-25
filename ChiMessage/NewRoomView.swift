//
//  NewRoomView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI
import FirebaseFirestore

struct NewRoomView: View {
    
    @State var title = ""
    @State var people = ""
    @State var message = ""
    @ObservedObject var convoModel = ConversationModel(userModel: UserModel())
    @Environment(\.presentationMode) var presentationMode
    
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
                            
                            TextField("Add People", text: $people) { (changing) in } onCommit: {
                                print("\(people) were added")
                            }.padding(.leading, 50)
                        }
                    }.padding(.leading, 20)
                }
                
                Spacer()
                
                //Bottm row, Textfield and send button
                HStack {
                    TextField("chimessage", text: $message) { (changing) in } onCommit: {
                        createRoomAndSend()
                    }.padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 50).strokeBorder(lineWidth: 2.5))
                    .gesture(DragGesture().onEnded({ (value) in
                        self.hideKeyboard()
                    }))
                    .accentColor(Color.white)
                    
                    Button {
                        
                        createRoomAndSend()
                        
                    } label: {
                        if message != "" {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 40.0))
                        } else {
                            Image(systemName: "arrow.up.circle")
                                .font(.system(size: 40.0))
                        }
                        
                    }.accentColor(self.cf().skyBlue)
                }.padding(.bottom, 5)
                .padding(.horizontal)
            }.background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
    
    func createRoomAndSend() {
        
        //TODO: add code here that makes sure that there is a group name and recipients
        if title != "" {
            convoModel.addConvo(title: title) {
                
                convoModel.getNewestConversation { (conversation) in
                    let mesModel = conversation
                    mesModel.addMessage(message: message)
                    
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
