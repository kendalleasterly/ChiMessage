//
//  PlaceholderConversationRow.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI

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
                    .foregroundColor(Color(red: 1, green: 1, blue: 1).opacity(opacity))
                    .frame(width: 21, height: 21)
                
            }
            
            //Name and last message
            VStack {
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color(red: 1, green: 1, blue: 1).opacity(opacity))
                        .frame(width: proxy.size.width * 0.65, height: 33)
                    
                    Spacer()
                    
                }
                HStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(self.secondaryLabelColor().opacity(opacity))
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
