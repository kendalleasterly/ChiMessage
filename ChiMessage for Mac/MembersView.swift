//
//  MembersView.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/7/20.
//

import SwiftUI


struct MembersView: View {
    
    @Environment (\.self.presentationMode) var presentationMode
    @ObservedObject var model: MessagesModel
    @State var users = [ChiUser]()
    @State var isShowingAddUsers: Double = 0
    @State var newUser = ""
   
    var body: some View {
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
                                
                                Text("􀆉")
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
                            
                            Text("􀁌")
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
                            
                            TextField("tim_cook", text: $newUser)
                                .font(.system(size: 28, weight: .bold))
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
                                        UserView(result: result)
                                    }
                                }
                                
                                Divider()
                                
                            }
                        }
                    }
                    Spacer()
                    
                }.padding(.horizontal)
                .background(Color.black.edgesIgnoringSafeArea(.all))
                
            }.background(updateSearchResults())
        
    }
    
    func updateSearchResults() -> EmptyView {
        print("update ran")
        if self.newUser != "" {
            
            model.searchForUser(user: newUser)
        } else {
            model.searchResults = [SearchResult(id: "1", name: "", userName: "")]
        }
        
        return EmptyView()
        
    }
    
}
