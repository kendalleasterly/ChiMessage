//
//  ConversationsView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI

struct ConversationsView: View {
    
    @EnvironmentObject var model: ConversationModel
    @ObservedObject var navModel: NavigationModel
    @State var isShowingNewMessageView = false
    @State var isshowingSignOutAlert = false
    
    var body: some View {
        List {
            ForEach(model.conversations) {conversation in
                
//                HStack{
                    NavigationLink(destination: MessageView(convo: conversation).environmentObject(model), label: {ConversationRows(convo: conversation)})
//                    Spacer()
//                }
                
                
            }
        }.listStyle(PlainListStyle())
        .padding(.horizontal)
        .sheet(isPresented: $isShowingNewMessageView) {
            NewRoomView()
        }.navigationBarTitle(Text("ChiMessage"))
        .navigationBarItems(leading:
                                Button(action: {
                                    
                                    isshowingSignOutAlert = true
                                    
                                }, label: {
                                    Image(systemName: "chevron.left.circle")
                                        .frame(width: 35, height: 35)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                })
                            , trailing:
                                Button(action: {
                                    
                                    self.isShowingNewMessageView = true
                                    
                                }, label: {
                                    Image(systemName: "plus.circle")
                                        .frame(width: 35, height: 35)
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                })
        )
        .alert(isPresented: $isshowingSignOutAlert, content: {
            
            let noButton = Alert.Button.default(Text("No"))
            let yesButton = Alert.Button.destructive(Text("Yes")) {
                model.signOut()
                navModel.conversationLinkActive = false
            }
            
            return Alert(title: Text("Are you sure you want to sign out?"), primaryButton: noButton, secondaryButton: yesButton)
        }).navigationBarBackButtonHidden(true)
    }
}
