//
//  ConversationsView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 10/17/20.
//

import SwiftUI

struct ConversationsView: View {
    
    @ObservedObject var model: ConversationModel
    @ObservedObject var navModel: NavigationModel
    @State var isShowingNewMessageView = false
    @State var isshowingSignOutAlert = false
    
    init(model: ConversationModel, navModel: NavigationModel) {
        self.model = model
        self.navModel = navModel
        print("conov view init")
        
    }
    
    var body: some View {
        GeometryReader { reader in
        ScrollView {
            VStack {
                
                if !model.conversations.isEmpty {
                    
                    ForEach(model.conversations) {conversation in
                        NavigationLink(destination: MessageView(convo: conversation).environmentObject(model), label: {ConversationRows(convo: conversation)})
                        
                        Divider().padding(.vertical, 5)
                        
                    }
                    
                } else {
                    ForEach(1..<10, id: \.self) {i in
                        
                        getPlaceholder(i: i, proxy: reader)
                        
                        Divider().padding(.vertical, 5)
                        
                    }
                }
                
                
            }
        }
    }
        .padding(.horizontal)
        .sheet(isPresented: $isShowingNewMessageView) {
            NewRoomView(model: model)
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
        ).onAppear(perform: {
            print("conversations view appeared")
            model.listen()
        })
        .alert(isPresented: $isshowingSignOutAlert, content: {
            
            let noButton = Alert.Button.default(Text("No"))
            let yesButton = Alert.Button.destructive(Text("Yes")) {
                model.signOut()
                navModel.conversationLinkActive = false
            }
            
            return Alert(title: Text("Are you sure you want to sign out?"), primaryButton: noButton, secondaryButton: yesButton)
        }).navigationBarBackButtonHidden(true)
    }
    
    func getPlaceholder(i: Int, proxy: GeometryProxy) -> PlaceholderConversationRow {
        
        let funcI = 10 - i
        let opacity = Double(funcI) / 10
        
        return PlaceholderConversationRow(opacity: opacity, proxy: proxy)
        
    }
    
}
