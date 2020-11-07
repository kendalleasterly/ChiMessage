//
//  MembersView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/23/20.
//

import SwiftUI

//TODO: figure out what to do with the sand color and how light it is in the messsage view
struct MembersView: View {
    
    @Environment (\.self.presentationMode) var presentationMode
    @ObservedObject var model: MessagesModel
    @State var users = [ChiUser]()
    @State var isShowingAddUsers: Double = 0
    @State var newUser = ""
    //TODO: manually update information in the members view, since at this level of heirarchy we don't get access to real updates
    var body: some View {
        ScrollViewReader{ reader in
            ScrollView {
                
                VStack{
                    ZStack{
                        TextField("Room Name", text: $model.convo.name) { (changing) in
                            if !changing {
                                
                                model.changeName(to: model.convo.name)
                            }
                        } onCommit: {
                            model.changeName(to: model.convo.name)
                        }
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(40)
                        
                        HStack{
                            Button {
                                self.presentationMode.wrappedValue.dismiss()
                            } label: {
                                
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .light))
                                    .frame(width: 15, height: 15)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        
                    }
                    Divider()
                    
                    ForEach(model.convo.people) {user in
                        if user.allowed {
                        MemberRow(model: model, user: user)
                            .padding(.vertical, 15)
                        }
                    }
                    
                    //TODO: make the function of saving stuff to the contact happen in one of these buttons rather than the exit button
                    Button {
                        if isShowingAddUsers == 0{
                            withAnimation (Animation.easeIn(duration: 0.2)) {
                            self.isShowingAddUsers = 45
                            }
                        } else {
                            withAnimation (Animation.easeIn(duration: 0.2)) {
                                self.isShowingAddUsers = 0
                            }
                            
                        }
                    } label: {
                        
                        HStack{
                            
                            Image(systemName: "plus.circle")
                                .foregroundColor(self.cf().white)
                                .rotationEffect(.init(degrees: self.isShowingAddUsers))
                            
                            Text("Add User")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            
                        }
                        .font(.system(size: 28, weight: .bold))
                        .padding(.vertical, 15)
                        
                    }
                    
                    if isShowingAddUsers == 45 {
                        HStack{
                            
                            Text("@")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            TextField("tim_cook", text: $newUser).onChange(of: self.newUser) { (value) in
                                if value != "" {
                                    
                                    model.searchForUser(user: value)
                                } else {
                                    model.searchResults = [SearchResult(id: "1", name: "", userName: "")]
                                }
                            }.font(.system(size: 28, weight: .bold))
                        }
                        if !model.searchResults.isEmpty && self.newUser != "" {
                            ForEach(model.searchResults.reversed()) {result in
                                
                                if result.id == "1" {
                                    
                                    Text("")
                                    
                                } else {
                                    
                                    Button {
                                        model.addUser(userID: result.id, name: result.name)
                                        self.newUser = ""
                                    } label: {
                                        UIUserView(result: result)
                                    }
                                }
                                
                                Divider()
                                
                            }
                        }
                    }
                    Spacer()
                    
                }.padding(.horizontal)
                .navigationBarHidden(true)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                
            }
        }
    }
    
}

struct EditContactView:View {
    
    var user: ChiUser
    var cs = ColorStrings()
    var convoID: String
    var model: MessagesModel
    @State var selection: String
    @State var isChatOnly = true
    @State var name: String
    @Environment (\.self.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader{ reader in
            let spacing = (reader.size.width - 220) / 5
            VStack{
                
                Spacer()
                ZStack{
                    //do a static text if its you, and a textfield if its someone else
                    Text("@kjeasterly31")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                    HStack{
                        Button {
                            var contact = Contact(id: user.id,
                                                  name: name, defaultColor: nil, colors: nil)
                            //TODO: do a check here that says if its the same and hasnt change, don't update
                            if !isChatOnly {
                                contact.defaultColor = selection
                                contact.colors = [convoID:selection]
                            } else {
                                contact.colors = [convoID:selection]
                            }
                            
                            model.updateContact(with: contact)
                            
                            self.presentationMode.wrappedValue.dismiss()
                            //TODO: use this only way of leaving as a chance to save changes and update the contact
                        } label: {
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 15, weight: .light))
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                            
                        }
                        Spacer()
                    }.padding(.leading)
                }
                Spacer()
                
                TextField("Name", text: $name)
                    .font(.system(size: 34, weight: .bold))
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                
                Divider()
                
                Spacer()
                
                ForEach(0..<6) {row in
                    
                    HStack{
                        Spacer()
                        
                        let multiplier = row * 4
                        
                        ForEach(multiplier..<multiplier + 4) {place in
                            
                            ColorDot(user: user, color: cs.array[place], selection: $selection)
                            
                            Spacer()
                            
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        
                        self.isChatOnly = true
                        
                    } label: {
                        ZStack{
                            if self.isChatOnly {
                                RoundedRectangle(cornerRadius: 40)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            } else {
                                RoundedRectangle(cornerRadius: 40).strokeBorder(lineWidth: 3)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            }
                            
                            Text("Just This One")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        
                        self.isChatOnly = false
                        
                    } label: {
                        ZStack{
                            
                            if !self.isChatOnly {
                                RoundedRectangle(cornerRadius: 40)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            } else {
                                RoundedRectangle(cornerRadius: 40).strokeBorder(lineWidth: 3)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            }
                            
                            
                            Text("All Chats")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            
                        }
                    }
                    
                    Spacer()
                    
                }.gesture(DragGesture().onEnded({ (value) in
                    self.hideKeyboard()
                }))
                
                Spacer()
                
            }.navigationBarHidden(true)
            .padding(.horizontal)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}
