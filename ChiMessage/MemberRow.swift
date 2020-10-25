//
//  MemberRow.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/23/20.
//

import SwiftUI

struct MemberRow: View {
    
    @State var isShowingEditContact = false
    @State var user: ChiUser
    let color: String
    @ObservedObject var model: MessagesModel
    
    var body: some View {
        
            HStack{
                
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 3, height: 30)
                    .padding(.trailing, 10)
                    .foregroundColor(user.getColorFrom(color: color))
                
                Text(user.name)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    
                    model.removeUser(user: user)
                    
                } label: {
                    Image(systemName: "person.badge.minus")
                        .padding(.trailing, 20)
                        .foregroundColor(user.getColorFrom(color: color))
                }
                
                Button {
                    
                    self.isShowingEditContact = true
                    
                } label: {
                    Image(systemName: "pencil.tip.crop.circle")
                        .foregroundColor(user.getColorFrom(color: color))
                }
                NavigationLink(destination: EditContactView(user: user,
                                                            convoID:self.model.id,
                                                            model: self.model, selection: color,
                                                            name: user.name),
                               isActive: $isShowingEditContact,
                               label: {EmptyView()})
            }.onTapGesture {
                self.isShowingEditContact = true
            }
            .font(.system(size: 28, weight: .bold))
        
    }
}

