//
//  ConversationRows.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/20/20.
//

import SwiftUI
import FirebaseAuth

struct ConversationRows: View {
    
    var convo: Conversation
    
    var body: some View {
        
        HStack{
            
            if getRead() {
                Circle().strokeBorder(lineWidth: 2.5)
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 20)
                    .foregroundColor(self.cf().white)
            } else {
                Circle()
                    .frame(width: 35, height: 35)
                    .padding(.trailing, 20)
                    .foregroundColor(self.cf().white)
            }
            
            
            VStack(alignment: .leading){
                
                Spacer()
                
                Text(convo.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack {
                    
                    ForEach(convo.people) {person in
                        
                        ZStack {
                            Circle()
                                .frame(width: 25, height: 25)
                                .foregroundColor(getUserColorFromUser(user: person))
                            
                            Text(person.name[0].uppercased())
                                .font(.caption)
                                .fontWeight(.semibold)
                        }.padding(.trailing, 5)
                    }
                }
                
                Spacer()
            }
        }.accentColor(.white)
    }
    
    func getUserColorFromUser(user: ChiUser) -> Color {
        
        if let colors = user.colors {
            if let color = colors[self.convo.id] {
                
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
    
    func getRead() -> Bool {
        
        if let profile = Auth.auth().currentUser {
            if let lastReadDate = convo.lastReadDates[profile.uid] {
                if lastReadDate < convo.lastMessage  {
                    
                    return false
                    
                } else {
                    return true
                }
            }
        }
        return false
        
    }
}


