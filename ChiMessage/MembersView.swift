//
//  MembersView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/23/20.
//

import SwiftUI

struct MembersView: View {
    
    @ObservedObject var model: MessagesModel
    @State var users = [ChiUser]()
    @State var isShowingAddUsers = false
    @State var newUser = ""
    
    var body: some View {
        
        NavigationView{
            ScrollView {
                
                VStack{
                    TextField("Room Name", text: $model.name) { (changing) in} onCommit: {
                        model.changeName(to: model.name)
                    }
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(40)
                    
                    Divider()
                    
                    ForEach(model.people) {user in
                        
                        MemberRow(user: user, color: getUserColorFromUser(user: user), model: model)
                            .padding(.vertical, 15)
                        
                    }
                    
                    //TODO: make the function of saving stuff to the contact happen in one of these buttons rather than the exit button
                    Button {
                        if !isShowingAddUsers {
                            self.isShowingAddUsers = true
                        } else {
                            self.isShowingAddUsers = false
                        }
                    } label: {
                        
                        HStack{
                            
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 3, height: 30)
                                .padding(.trailing, 10)
                                .foregroundColor(self.cf().white)
                            
                            Text("Add User")
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle")
                                .foregroundColor(self.cf().white)
                        }
                        .font(.system(size: 28, weight: .bold))
                        .padding(.vertical, 15)
                        
                    }
                    
                    if isShowingAddUsers {
                        TextField("timcook", text: $newUser) {changing in} onCommit: {
                            self.newUser = ""
                            
                        }.onChange(of: self.newUser) { (value) in
                            if value != "" {
                                print(value)
                                
                                var groupIDs = [String]()
                                
                                for person in model.people {
                                    groupIDs.append(person.id)
                                }
                                model.searchForUser(user: value, groupIDs: groupIDs)
                            } else {
                                model.searchResults = [SearchResult]()
                            }
                           
                            
                        }
                        
                        if !model.searchResults.isEmpty {
                            ForEach(model.searchResults) {result in
                                
                                Button {
                                    model.addUser(userID: result.id, name: result.name)
                                } label: {
                                    VStack{
                                        Text(result.name)
                                        Text(result.userName)
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                    
                }.padding(.horizontal)
                
            }.onChange(of: model.people, perform: { (value) in
                print(value)
            })
            .navigationBarHidden(true)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        
    }
    
    func getUserColorFromUser(user: ChiUser) -> String {
        
        if let colors = user.colors {
            if let color = colors[self.model.id] {
                
                return color
            } else {
                //this one and the next one do the same, they are repeated because there can be rooms but this one may not be included
                return user.color
            }
        } else {
            //this is if there are no rooms at all
            return user.color
        }
    }
    
}

struct EditContactView:View {
    
    var user: ChiUser
    var cs = ColorStrings()
    var convoID: String
    @State var model: MessagesModel
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
                            
                            Image(systemName: "chevron.left")
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
