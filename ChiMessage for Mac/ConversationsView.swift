//
//  ConversationsView.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI

struct ConversationsView: View {
    
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var navModel: NavigationModel
    @ObservedObject var model: ConversationModel
    @State var isShowingNewMessageView = false
    @State var isshowingSignOutAlert = false
    @State var selectedConversation: Conversation? = nil
    @State var searchText = ""
    
    init(model: ConversationModel) {
        self.model = model
        print("conov view init")
        
    }
    
    var body: some View {
        
        HStack(spacing: 0) {
            //Side bar with conversations
            ZStack(alignment: .leading) {
               
                RoundedRectangleWithoutTop()
                    .frame(width: 350)
                
                VStack(spacing: 20) {
                    
                    //Search bar
                    HStack {
                        
                        Text("􀊫").foregroundColor(self.tertiaryLabelColor())
                        
                        TextField("Search", text: $searchText)
                    }
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background( RoundedRectangle(cornerRadius: 15).foregroundColor( self.cf().black))
                    .padding(.top)
                    
                    //Indicator and add button
                    //TODO: when the conversations  button is clicked, hide them
                    
                    HStack {
                        Text("PEOPLE")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                            .opacity(0.3)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Text("")
                        }.buttonStyle(AddButton())

                    }
                    
                    ForEach(getPeopleConvos()) {conversation in
                        
                        
                            Button {
                                withAnimation {
                                    self.selectedConversation = conversation
                                }
                                
                            } label: {
                                Text("")
                                
                            }.buttonStyle(ConversationRowButton(conversation: conversation))
                        
                        
                    }
                    
                    HStack {
                        Text("CONVERSATIONS")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                            .opacity(0.3)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Text("")
                        }.buttonStyle(AddButton())

                    }
                    
                    
                    ForEach(getGroupConvos()) {conversation in
                        
                        Button {
                            withAnimation {
                                self.selectedConversation = conversation
                            }
                            
                        } label: {
                            Text("")
                            
                        }.buttonStyle(ConversationRowButton(conversation: conversation))
                        
                        
                    }
                    
                    Spacer()
                }.frame(width: 330)
                .padding(.leading, 10)
                
            }
            //Main content with messages
            
            MessageView(convo: selectedConversation, convoModel: self.model)
                .frame(minWidth: 500)
            Spacer()
        }
    }
    
    func getPeopleConvos() -> [Conversation] {
        
        var conversationArray = [Conversation]()
        
        for conversation in model.conversations {
            
            var allowedPeople = [ChiUser]()
            for person in conversation.people {
                if person.allowed {
                    allowedPeople.append(person)
                }
            }
            
            if allowedPeople.count == 2 {
                conversationArray.append(conversation)
            }
            
        }
        
        return conversationArray
    }
    
    func getGroupConvos() -> [Conversation] {
        
        var conversationArray = [Conversation]()
        
        for conversation in model.conversations {
            
            var allowedPeople = [ChiUser]()
            for person in conversation.people {
                if person.allowed {
                    allowedPeople.append(person)
                }
            }
            
            if allowedPeople.count != 2 {
                conversationArray.append(conversation)
            }
            
        }
        
        return conversationArray
    }
    
}

struct ConversationRowButton: ButtonStyle {
    
    var conversation: Conversation
    
    func makeBody(configuration: Configuration) -> some View {
        
        
        ConversationRows(convo: conversation)
            .frame(width: 330)
            .background(Color(red: 60 / 255, green: 60 / 255, blue: 67 / 255).opacity(0.001))
        
    }
}

struct AddButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        Text("􀁌")
            .foregroundColor(.white)
            .fontWeight(.medium)
            .opacity(0.8)
    }
    
}

struct RoundedRectangleWithoutTop: View {
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Rectangle()
                .frame(height: 20)
                .edgesIgnoringSafeArea(.top)
                .foregroundColor(Color(red: 26 / 255, green: 26 / 255, blue: 30 / 255))

            
            RoundedRectangle(cornerRadius: 10)
                .edgesIgnoringSafeArea(.top)
                .foregroundColor(Color(red: 26 / 255, green: 26 / 255, blue: 30 / 255))

            
           
        }
        
    }
    
}
