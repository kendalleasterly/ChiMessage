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
        
        VStack(spacing: 0){
            
            HStack{
                Text(message.array[0].name)
                    .font(.body)
                    .fontWeight(.semibold)
                
                
                Spacer()
            }.padding(.vertical, 5)
            
            ForEach(message.array) {message in
                
                HStack{
                    
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 3, height: 30)
                        .foregroundColor(message.color)
                    
                    Text(message.message)
                        .font(.body)
                    
                    Spacer()
                }
            }
        }
    }
}

struct UserMessageRow: View {
    
    var message: MessageThread
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Spacer()
                Text(message.array[0].name)
                    .font(.body)
                    .fontWeight(.semibold)
            }.padding(.vertical, 5)
            
            ForEach(message.array) {message in
                
                HStack{
                    Spacer()
                    
                    Text(message.message)
                        .font(.body)
                        .multilineTextAlignment(.trailing)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 3, height: 30)
                        .foregroundColor(message.color)
                }
            }
        }
    }
}
