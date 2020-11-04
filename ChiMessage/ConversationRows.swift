//
//  ConversationRows.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/20/20.
//

import SwiftUI
import FirebaseAuth

struct ConversationRows: View {
    
    @ObservedObject var convo: Conversation
    
    var body: some View {
        
        
        HStack {
            
            //Contact photo
            ZStack {
                
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(self.cf().black)
                
                Text(getInitials())
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(decideColor()[0].opacity(0.8))
                
                
            }
            
            
            //Name and last message
            VStack {
                HStack {
                    Text(convo.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                }
                HStack {
                    Text(convo.previewMessage)
                        .font(.body)
                        .foregroundColor(Color(UIColor.secondaryLabel))
                        .lineLimit(1)
                    //TODO: add line limits to all texts where needed (eg. conversation names in all places)
                    //TODO: figure out what happens when a user logs in and what happens with the contacts. I think auth's user id might be outdatated, and might not be recognizing the fact that a user just
                    Spacer()
                    
                }
            }
            //amount of unread memssages
            
            Spacer()
            
            if convo.unreadMessages != 0 {
                Text("\(convo.unreadMessages)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: unreadLessThanTen() ? 21 : nil, height: 21)
                    .padding(.horizontal, !unreadLessThanTen() ? 5 : 0 )
                    .background(RoundedRectangle(cornerRadius: 30).foregroundColor(decideColor()[1]))
            }
            
        }
    }
    
    //TODO: ALSO, remove the ability to edit the name of the convo if its only you and another person
    //TODO: fix the messages view and make sure that when i tap the bar it scrolls to the bottom. You could ry removing the scrolling animation or making it longer
    func unreadLessThanTen() -> Bool {
        
        if convo.unreadMessages < 10 {
            return true
        } else {
            return false
        }
    }
    
    func decideColor() -> [Color] {
        
        //the first is the color of the contact letters, and the second is the color of the message indicator
        var funcColor = [.white, convo.lastSenderColor]
        
        var allowedPeople = [ChiUser]()
        for person in convo.people {
            if person.allowed {
                allowedPeople.append(person)
            }
        }
        
        if allowedPeople.count == 2 {
            
            for person in allowedPeople {
                
                if let profile = Auth.auth().currentUser {
                    if person.id != profile.uid {
                        
                        //if we have a color for this convo
                        if let colors = person.colors {
                            if let color = colors[convo.id] {
                                funcColor[0] = person.getColorFrom(color: color)
                                funcColor[1] = person.getColorFrom(color: color)
                            } else {
                                funcColor[0] = person.cColor
                                funcColor[1] = person.cColor
                            }
                        } else {
                            funcColor[0] = person.cColor
                            funcColor[1] = person.cColor
                        }
                        
                    }
                }
            }
        }
        
        return funcColor
    }
    
    //function to figure out initals
    func getInitials() -> String {
        
        let words = convo.name.split(separator: " ")
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

struct PlaceholderConversationRow: View {
    
    var opacity: Double = 1.0
    var proxy: GeometryProxy
    
    var body: some View {
        
        HStack {
            
            //Contact photo
            ZStack {
                
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(self.cf().black)
                
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(.white).opacity(opacity))
                    .frame(width: 21, height: 21)
                
            }
            
            //Name and last message
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color(.white).opacity(opacity))
                        .frame(width: proxy.size.width * 0.65, height: 33)
                    
                    Spacer()
                    
                }
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color(UIColor.secondaryLabel).opacity(opacity))
                        .frame(width: proxy.size.width * 0.7, height: 20)
                    
                    //TODO: add line limits to all texts where needed (eg. conversation names in all places)
                    //TODO: figure out what happens when a user logs in and what happens with the contacts. I think auth's user id might be outdatated, and might not be recognizing the fact that a user just
                    Spacer()
                    
                }
            }
            //amount of unread memssages
            
            Spacer()
            
        }
        
    }
}
