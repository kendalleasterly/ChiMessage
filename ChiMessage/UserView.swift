//
//  UserView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/30/20.
//

import SwiftUI
import AppKit

struct UserView: View {
    
    var result: SearchResult
    
    var body: some View {
        
        HStack{
            VStack(alignment: .leading){
                Text(result.name)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("@" + result.userName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(NSColor.tertiaryLabelColor))
            }
            
            Spacer()
            
        }
        
    }
}
