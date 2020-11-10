//
//  ContentView.swift
//  ChiMessage for Mac
//
//  Created by Kendall Easterly on 11/6/20.
//

import SwiftUI
import FirebaseAuth


struct AuthView: View {
    
    @EnvironmentObject var authModel: AuthModel
    @EnvironmentObject var navModel: NavigationModel
    @ObservedObject var userModel: UserModel
    var conversationModel: ConversationModel
    
    init() {
        
        let userModel = UserModel()
        self.userModel = userModel
        self.conversationModel = ConversationModel(userModel: userModel)
        
    }
    
    var body: some View {
        
//        Group{
            if authModel.isSignedIn {
                
                ConversationsView(model: conversationModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
//                TestView()
                
            } else {
                SignUpFlow()
                
            }
//        }//.frame(maxWidth: .infinity, maxHeight: .infinity)

        
    }
}
