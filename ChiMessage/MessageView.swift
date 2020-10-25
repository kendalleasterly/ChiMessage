//
//  MessageView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI
//import GoogleSignIn

struct MessageView: View {
    
    @Environment (\.self.presentationMode) var presentationMode
    @ObservedObject var model: MessagesModel
    @State var message = ""
    @State var isShowingUsersView = false
    //    @State var updater = 0
    var id: String
    
    //TODO: make an option how to sort. Right now its automatically by the last message, but I've also creted a property in each room that tells when it was created.
    var body: some View {
        GeometryReader { reader in
            ScrollViewReader { proxy in
                
                ZStack {
                    //Main VStack for messages and sending content
                    VStack(spacing: 0) {
                        
                        ScrollView{
                            
                            ForEach(model.messages) {thread in
                                
                                if thread.array[0].isUsers {
                                    UserMessageRow(message: thread)
                                } else {
                                    RecipientMessageRow(message: thread)
                                }
                            }
                        }.onChange(of: model.messages) { (value) in
                            if !model.messages.isEmpty {
                                proxy.scrollTo(model.messages.last!.id)
                            } else {
                                print("messages were empty, so I didn't scroll")
                            }
                        }.padding(.vertical)
                        HStack {
                            TextField("chimessage", text: $message) { (changing) in
                                withAnimation {proxy.scrollTo(model.messages.last!.id) }
                            } onCommit: {
                                model.addMessage(message: message)
                                message = ""
                                
                            }.padding(.horizontal, 30)
                            .padding(.vertical, 10)
                            .overlay(RoundedRectangle(cornerRadius: 50).strokeBorder(lineWidth: 2.5))
                            .gesture(DragGesture().onEnded({ (value) in
                                self.hideKeyboard()
                            }))
                            .gesture(TapGesture().onEnded({ nothing in
                                withAnimation {proxy.scrollTo(model.messages.last!.id) }
                            }))
                            .accentColor((Color(UIColor(red: 237 / 255, green: 241 / 255, blue: 241 / 255, alpha: 1.0))))
                            
                            Button {
                                
                                model.addMessage(message: message)
                                self.message = ""
                                
                            } label: {
                                
                                if message != "" {
                                    withAnimation {
                                        Image(systemName: "arrow.up.circle.fill")
                                            .font(.system(size: 40.0))
                                    }
                                } else {
                                    withAnimation { Image(systemName: "arrow.up.circle")
                                        .font(.system(size: 40.0)) }
                                }
                                
                            }.accentColor(getUserColorFromUser(user: model.getMyChiUser()))
                        }
                        .padding(.bottom, 5)
                    }//end of bottommost vstack for all sending content
                    .padding(.horizontal)
                    .padding(.top, 80)
                    
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
                                                .foregroundColor(self.cf().card)
                                                .frame(width: 40, height: 40)
                                            
                                            //Content
                                            
                                            Text(model.room.name[0].uppercased())
                                                .font(.system(size: 22, weight: .bold))
                                            
                                        }
                                        
                                        //Name
                                        Text(model.room.name)
                                            .font(.system(size: 28, weight: .bold))
                                            .multilineTextAlignment(.center)
                                        
                                        
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
                        
                        Spacer()
                    }//end of topmost Vstack, for the top bar
                    
                }//end of main Zstack
                .onAppear {
                    proxy.scrollTo(model.messages.last!.id)
                }
                //                .onChange(of: model.getConversationFromId(id: id).people) { (value) in
                //                    self.updater = Int.random(in: 1...100)
                //                }
                
            }//End of scrollviewreader
        }//End of geometry reader
        .navigationTitle(Text(""))
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingUsersView) {
            MembersView(model: model)
        }
        
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
    
}

//when you create the edit view, you can have images for the google users.
//you should also try to change the user's color using a nice color picker view


struct MessageThread:Identifiable, Hashable {
    
    var id: Int
    var senderID: String
    var array: [Message]
    
}
