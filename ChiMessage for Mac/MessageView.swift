//
//  MessageView.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/7/20.
//

import SwiftUI

struct MessageView: View {
    
    
    @EnvironmentObject var navModel: NavigationModel
    @Environment (\.self.presentationMode) var presentationMode
    @ObservedObject var convoModel: ConversationModel
    @ObservedObject var model: MessagesModel
    @State var message = ""
    @State var isShowingUsersView = false
    
    
    init(convo: Conversation?, convoModel: ConversationModel) {
        
        let dummyModel = MessagesModel(room: nil)
        
        if let conversation = convo {
            if let model = convoModel.mesModels[conversation.id] {
                self.model = model
            } else {
                self.model = dummyModel
            }
        } else {
            self.model = dummyModel
        }
        
        self.convoModel = convoModel
    }
    
    //TODO: make an option how to sort. Right now its automatically by the last message, but I've also creted a property in each room that tells when it was created.
    var body: some View {
        if model.convo.name != "" {
            ZStack {
                
                //Bottom section with messages
                
                VStack(spacing: 0){
                    
                    ScrollView{
                        ScrollViewReader {proxy in
                            
                            Rectangle()
                                .frame(height: 75)
                                .foregroundColor(Color(red: 12 / 255, green: 12 / 255, blue: 14 / 255))
                            
                            ForEach(model.messages) { message in
                                
                                if message.array.first!.isUsers {
                                    
                                    UserMessageRow(message: message)
                                    
                                } else {
                                    RecipientMessageRow(message: message)
                                }
                            }.padding(.horizontal)
                            .padding(.vertical)
                            .onReceive(model.$messages) { (value) in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                    withAnimation {
                                        if let lastMessage = model.messages.last {
                                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                        }
//                                    }
                                }
                            }
                        }
                    }
                    
                    //Entire Bottom bar with send and textfield
                    
                    HStack {
                        //actual text entry place
                        TextField("chimessage", text: $message) { (changing) in } onCommit: {
                            model.addMessage(message: message)
                            message = ""
                            
                        }.foregroundColor((Color(NSColor(red: 237 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1.0))))
                        .textFieldStyle(PlainTextFieldStyle())
                        
                        Spacer()
                        
                        //send button
                        Button {
                            
                            
                            
                            model.addMessage(message: message)
                            self.message = ""
                            self.isShowingUsersView = true
                        } label: {
                            
                            if message != "" {
                                withAnimation {
                                    Text("􀁷")
                                        .font(.system(size: 25.0, weight: .bold))
                                }
                            } else {
                                withAnimation {
                                    Text("􀁶")
                                        .font(.system(size: 25.0, weight: .bold))
                                    
                                }
                            }
                            
                        }.foregroundColor(getUserColorFromUser(user: model.getMyChiUser()))
                        .buttonStyle(PlainButtonStyle())
                    }.padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 15)
                                    .foregroundColor(self.cf().black))
                    .padding([.horizontal, .bottom])
                    
                    
                    
                }.edgesIgnoringSafeArea(.top)
                
                //Top section with descrition and send button
                
                ZStack(alignment: .bottom) {
                    
                    RoundedRectangleWithoutTop()
                        .frame(height: 75)
                        .foregroundColor(Color(red: 26 / 255, green: 26 / 255, blue: 30 / 255))
                        
                    
                    HStack {
                        
                        ZStack {
                            
                            Circle()
                                .frame(width: self.contactSize(), height: self.contactSize())
                                .foregroundColor(self.cf().black)
                            
                            Text("TD")
                            
                        }
                        
                        Text(model.convo.name)
                            .title()
                        
                        
                        Spacer()
                        
                        Text(model.convo.nameSummary)
                            .foregroundColor(self.secondaryLabelColor())
                        
                        Button {
                            
                        } label: {
                            Text("")
                        }.buttonStyle(InfoButton())

                        
                    }.padding([.horizontal, .bottom])
                    
//                    .edgesIgnoringSafeArea(.top)
                    
                }
                .top()
                .edgesIgnoringSafeArea([.top, .trailing])
            }
            .onAppear {
                
                model.updateReadStatus()
                
            }
            .sheet(isPresented: $isShowingUsersView) {
                MembersView(model: model)
            }
        } else {
            Text("")
                
        }
        //Containter for whole view
        
        
    }//End of main body
    
    func getUserColorFromUser(user: ChiUser) -> Color {
        
        if let colors = user.colors {
            if let color = colors[self.model.convo.id] {
                
                return user.getColorFrom(color: color)
            } else {
                //this one and the next one do the same, they are repeated because there can be rooms but this one may not be included
                return user.cColor
            }
        } else {
            //this is if there are no rooms at all
            return user.cColor
        }
    }
    
    func getInitials() -> String {
        
        let words = model.convo.name.split(separator: " ")
        var initials = ""
        
        var i = 0
        for word in words {
            
            if i <= 1 {
                let funcWord = word.description
                
                initials = initials + funcWord[0]
            }
            
            i = i + 1
        }
        
        return initials.uppercased()
        
    }
}

struct InfoButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        
        Text("􀅴")
        
    }
    
}
