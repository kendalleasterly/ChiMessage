//
//  ColorDot.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/23/20.
//

import SwiftUI

struct ColorDot: View {
    
    @State var user: ChiUser
    @State var color: String
    @Binding var selection: String
    
    var body: some View {
        
        Button {
            
            withAnimation(Animation.easeIn(duration: 0.1)) {
                selection = color
            }
            
        } label: {
            ZStack{
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(user.getColorFrom(color: color))
                
                if color == selection {
                    
                    Circle().stroke(lineWidth: 3)
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.white)
                }
            }
        }
    }
}
