//
//  MessageView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI

struct MessageView: View, Equatable {
    
    @EnvironmentObject var convoModel: ConversationModel
    @Environment (\.self.presentationMode) var presentationMode
    @State var message = ""
    @State var isShowingUsersView = false
    
    var model: MessagesModel

    init(convo: Conversation) {
        
        let model = MessagesModel(room: convo)
        self.model = model
        
    }
    
    //TODO: make an option how to sort. Right now its automatically by the last message, but I've also creted a property in each room that tells when it was created.
    var body: some View {
        GeometryReader { reader in
            ScrollViewReader { proxy in
                
                ZStack {
                    //Main VStack for messages and sending content
                    VStack(spacing: 0) {
                        
                        ScrollView{
                            //put these two in a vstack
                            
                            Rectangle()
                                .frame(width: reader.size.width / 2, height: 70)
                                .foregroundColor(Color(UIColor.systemBackground))
                                
                            ForEach(model.messages) {thread in
                                
                                if thread.array[0].isUsers {
                                    UserMessageRow(message: thread)
                                        .padding(.bottom)
                                } else {
                                    RecipientMessageRow(message: thread)
                                        .padding(.bottom)
                                }
                            }
                            
                        }.onChange(of: model.messages) { (value) in
                            if !model.messages.isEmpty {
                                withAnimation(Animation.easeIn(duration: 0.15)) {
                                    proxy.scrollTo(model.messages.last!.id, anchor: .bottom)
                                    
                                    
                                }
                            } else {
                                print("messages were empty, so I didn't scroll")
                            }
                        }.padding(.top)
                        
                        HStack {
                            TextField("chimessage", text: $message) { (changing) in
                                withAnimation {proxy.scrollTo(model.messages.last!.id, anchor: .bottom) }
                            } onCommit: {
                                model.addMessage(message: message)
                                message = ""
                                
                            }.accentColor((Color(UIColor(red: 237 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1.0))))
                            Spacer()
                            
                            Button {
                                
                                model.addMessage(message: message)
                                self.message = ""
                                
                            } label: {
                                
                                if message != "" {
                                    withAnimation {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 25.0, weight: .bold))
                                    }
                                } else {
                                    withAnimation { Image(systemName: "arrow.up.circle")
                                        .font(.system(size: 25.0, weight: .bold))
                                        
                                    }
                                }
                                
                            }.accentColor(getUserColorFromUser(user: model.getMyChiUser()))
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 15).foregroundColor(self.cf().black))
                        .gesture(DragGesture().onEnded({ (value) in
                            self.hideKeyboard()
                        }))
                        
                        .padding(.bottom)
                        
                    }//end of bottommost vstack for all sending content
                    .padding(.horizontal)
//                    .padding(.top, 80)
                    
                    //Top Bar, vstack for spacing
                    VStack {
                        
                        //Stack so all the top bar content can be in the right place
                        ZStack {
                            VStack{
                                //Background bar
                                Rectangle()
                                    .foregroundColor(self.cf().background)
                                    .background(Blur())
                                    .frame(width: reader.size.width, height: 140)
                                    .clipShape(RoundedRectangle(cornerRadius: 30))
                                    .edgesIgnoringSafeArea(.top)
                                
                                Spacer()
                                
                            }
                            
                            //for the name and then people at bottom
                            VStack {
                                //The back button is at the top, its there so it doesn't interefere with the positioning of the content
                                ZStack{
                                    //Name and card
                                    HStack {
                                        
                                        //Card
                                        ZStack {
                                            //Background
                                            Circle()
                                                .foregroundColor(self.cf().black)
                                                .frame(width: 40, height: 40)
                                            
                                            //Content
                                            
                                            Text(getInitials())
                                                .font(.callout)
                                                .fontWeight(.semibold)
                                                
                                            
                                        }
                                        
                                        //Name
                                        Text(model.room.name)
                                            .font(.system(size: 28, weight: .bold))
                                            .multilineTextAlignment(.center)
                                            .lineLimit(1)
                                        
                                        
                                    }//end of name and card hstack
                                    
                                    //back button
                                    HStack {
                                        
                                        Button {
                                            presentationMode.wrappedValue.dismiss()
                                        } label: {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 15, weight: .light))
                                                .frame(width: 15, height: 15)
                                                .foregroundColor(.white)
                                        }
                                        
                                        
                                        Spacer()
                                    }.padding(.leading)
                                    
                                }
                                //People
                                
                                Text(model.room.nameSummary)
                                
                                Spacer()
                            }//end of vstack for all the content in top bar
                            .padding(.top, 5)
                            .onTapGesture {
                                
                                self.isShowingUsersView = true
                            }
                            
                        }//End of topmost ZStack for the top bar
                        NavigationLink(destination: MembersView().environmentObject(model), isActive: $isShowingUsersView) {
                            EmptyView()
                        }
                        Spacer()
                    }//end of topmost Vstack, for the top bar
                    
                }//end of main so you didn't have to be there I will finish my show face Zstack
                .onAppear {
                    proxy.scrollTo(model.messages.last!.id, anchor: .bottom)
                    
                }
                .onDisappear {
                    
                    model.updateReadStatus()
                    model.room.unreadMessages = 0
                }
                
            }//End of scrollviewreader
        }//End of geometry reader
        .navigationTitle(Text(""))
        .navigationBarHidden(true)
        
    }//End of main body
    
    func getUserColorFromUser(user: ChiUser) -> Color {
        
        if let colors = user.colors {
            if let color = colors[self.model.room.id] {
                
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
        
        let words = model.room.name.split(separator: " ")
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
    
    static func == (lhs: MessageView, rhs: MessageView) -> Bool {
        return true
    }
    
}
