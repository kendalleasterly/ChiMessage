//
//  Bubble.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/16/20.
//

import SwiftUI

struct RecipientMessageRow: View {
    
    var message: MessageThread
    
    var body: some View {
        
        VStack(spacing: 5) {
            
            //contact photo and name
            HStack {
                
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(self.cf().black)
                    
                    Text(getInitials())
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(message.array.first!.color.opacity(0.8))
                    
                }
                
                Text(message.array.first!.name.split(separator: " ").first!.description)
                    .font(.body)
                    .fontWeight(.semibold)
                
                Spacer()
                
            }
            
            // each message paired with a black circle
            
            ForEach(message.array) { item in
                HStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(Color(UIColor.systemBackground))
                    
                    Text(item.message)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(message.array.first!.color))
                    
                    Spacer()
                    
                }
            }
        }
    }
    
    func getInitials() -> String {
        
        let words = message.array.first!.name.split(separator: " ")
        var initials = ""
        print(words)
        
        var i = 0
        for word in words {
            print(word.description)
            if i <= 1 {
                var funcWord = word.description
                
                initials = initials + funcWord[0]
            }
            
            i = i + 1
        }
        
        return initials.uppercased()
        
    }
    
}

struct UserMessageRow: View {
    
    var message: MessageThread
    
    var body: some View {
        
        VStack(spacing: 5) {
            
            //contact photo and name
            HStack {
                
                Spacer()
                
                Text(message.array.first!.name.split(separator: " ").first!.description)
                    .font(.body)
                    .fontWeight(.semibold)
                
            }
            
            // each message paired with a black circle
            
            ForEach(message.array) { item in
                HStack {
                    
                    Spacer()
                    
                    Text(item.message)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(message.array.first!.color))
                    
                }
            }
        }
        
    }
}
