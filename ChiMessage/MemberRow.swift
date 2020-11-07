//
//  MemberRow.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/23/20.
//

import SwiftUI

struct MemberRow: View {
                    
    @ObservedObject var model: MessagesModel
    @State var isShowingEditContact = false
    @State var user:ChiUser
                
    var body: some View {
        
        HStack{
            
            Button {
                
                self.isShowingEditContact = true
                
            } label: {
                Image(systemName: "pencil.tip.crop.circle")
                    .foregroundColor(user.getColorFrom(color: getUserColorFromUser()))
            }
            
            Text(user.name)
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                
                model.removeUser(user: user)
                
            } label: {
                Image(systemName: "person.badge.minus")
                    .foregroundColor(user.getColorFrom(color: getUserColorFromUser()))
            }
            
        }.onTapGesture {
            self.isShowingEditContact = true
        }
        .font(.system(size: 28, weight: .bold))
        .sheet(isPresented: $isShowingEditContact) {
            EditContactView(user: user,
                            convoID:self.model.convo.id,
                            model: self.model, selection: getUserColorFromUser(),
                            name: user.name)
        }.onAppear {
            
            print(model.convo.people)
            
        }
    }
    
    func getMostRecentUser() -> ChiUser? {
        
        for funcUser in model.convo.people {
            
            if funcUser.id == user.id {
                print("found most recent user \(funcUser.name)")
                return funcUser
            }
            
        }
        
        return nil
        
    }
    
    func getUserColorFromUser() -> String {
        
        if let user = getMostRecentUser() {
            
            if let colors = user.colors {
                if let color = colors[self.model.convo.id] {
                    
                    return color
                } else {
                    //this one and the next one do the same, they are repeated because there can be rooms but this one may not be included
                    return user.color
                }
            } else {
                //this is if there are no rooms at all
                return user.color
            }
            
        } else {
            print("couldn't return user on account of the fact that they are not in the most recent array in member row")
            return "white"
        }
        
        
    }
    
}

