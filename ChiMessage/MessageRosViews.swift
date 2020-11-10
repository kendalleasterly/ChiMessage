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
                        .frame(width: self.contactSize(), height: self.contactSize())
                        .foregroundColor(self.cf().black)
                    
                    Text(getInitials())
                        .contactText()
                        .foregroundColor(message.array.first!.color.opacity(0.8))
                    
                }
                
                Text(message.array.first!.name.split(separator: " ").first!.description)
                    .fontWeight(.semibold)
                
                Spacer()
                
            }
            
            // each message paired with a black circle
            
            ForEach(message.array) { item in
                HStack {
                    
                    Text(item.message)
                        .padding(.vertical, 10)
                        .padding(.horizontal, messageLessThanTen(message: item) ? 15 : 10)
                        .background(RoundedRectangle(cornerRadius: 15)
                                        .foregroundColor(message.array.first!.color))
                        .padding(.leading, self.contactSize() + 10)
                    Spacer()
                    
                }
            }
        }
    }
    
    func getInitials() -> String {
        
        let words = message.array.first!.name.split(separator: " ")
        var initials = ""
        
        
        var i = 0
        for word in words {
            
            if i <= 1 {
                var funcWord = word.description
                
                initials = initials + funcWord[0]
            }
            
            i = i + 1
        }
        
        return initials.uppercased()
        
    }
    
    func messageLessThanTen(message: Message) -> Bool {
        print("\(message.message) \(message.message.count)")
        if message.message.count == 1 {
            
            return true
        } else {
            return false
        }
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
