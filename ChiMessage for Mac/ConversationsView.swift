//
//  ConversationsView.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI

struct ConversationsView: View {
    
    @EnvironmentObject var authModel: AuthModel
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
        NavigationView{
            List{
                ForEach(model.conversations) {conversation in
                    
                    NavigationLink(destination: MessageView(convo: conversation)) {
                        ConversationRows(convo: conversation)
                    }
                }
            }.listStyle(SidebarListStyle())
            .padding(5)
            .frame(minWidth: 350)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
