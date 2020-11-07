//
//  EditContactView.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI

struct EditContactView:View {
    
    var user: ChiUser
    var cs = ColorStrings()
    var convoID: String
    var model: MessagesModel
    @State var selection: String
    @State var isChatOnly = true
    @State var name: String
    @Environment (\.self.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader{ reader in
            let spacing = (reader.size.width - 220) / 5
            VStack{
                
                Spacer()
                ZStack{
                    //do a static text if its you, and a textfield if its someone else
                    Text("@kjeasterly31")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(NSColor.tertiaryLabelColor))
                    HStack{
                        Button {
                            var contact = Contact(id: user.id,
                                                  name: name, defaultColor: nil, colors: nil)
                            //TODO: do a check here that says if its the same and hasnt change, don't update
                            if !isChatOnly {
                                contact.defaultColor = selection
                                contact.colors = [convoID:selection]
                            } else {
                                contact.colors = [convoID:selection]
                            }
                            
                            model.updateContact(with: contact)
                            
                            self.presentationMode.wrappedValue.dismiss()
                            //TODO: use this only way of leaving as a chance to save changes and update the contact
                        } label: {
                            
                            Text("􀆄")
                                .font(.system(size: 15, weight: .light))
                                .frame(width: 15, height: 15)
                                .foregroundColor(.white)
                            
                        }
                        Spacer()
                    }.padding(.leading)
                }
                Spacer()
                
                TextField("Name", text: $name)
                    .font(.system(size: 34, weight: .bold))
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                
                Divider()
                
                Spacer()
                
                ForEach(0..<6) {row in
                    
                    HStack{
                        Spacer()
                        
                        let multiplier = row * 4
                        
                        ForEach(multiplier..<multiplier + 4) {place in
                            
                            ColorDot(user: user, color: cs.array[place], selection: $selection)
                            
                            Spacer()
                            
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    
                    Button {
                        
                        self.isChatOnly = true
                        
                    } label: {
                        ZStack{
                            if self.isChatOnly {
                                RoundedRectangle(cornerRadius: 40)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            } else {
                                RoundedRectangle(cornerRadius: 40).strokeBorder(lineWidth: 3)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            }
                            
                            Text("Just This One")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        
                        self.isChatOnly = false
                        
                    } label: {
                        ZStack{
                            
                            if !self.isChatOnly {
                                RoundedRectangle(cornerRadius: 40)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            } else {
                                RoundedRectangle(cornerRadius: 40).strokeBorder(lineWidth: 3)
                                    .frame(width: (100 + spacing), height: 45)
                                    .foregroundColor(user.getColorFrom(color: selection))
                            }
                            
                            
                            Text("All Chats")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            
                        }
                    }
                    
                    Spacer()
                    
                }
                
                Spacer()
                
            }.padding(.horizontal)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}
